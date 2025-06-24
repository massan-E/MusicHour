class Program < ApplicationRecord
  include ImageProcessable
  attr_accessor :invitation_token

  validates :title, presence: true,
                   uniqueness: { case_sensitive: false }, # 大文字小文字を区別しない
                   length: { maximum: 100 }
  validates :body, allow_nil: true, length: { maximum: 255 }

  belongs_to :user
  has_many :user_participations, dependent: :destroy
  has_many :participants, through: :user_participations, source: :user
  has_many :letterboxes, dependent: :destroy
  has_many :letters, dependent: :nullify

  has_one_attached :image

  has_one :program_ranking, dependent: :destroy

  scope :search, ->(q) { where("title LIKE ?", "%#{q}%").limit(6) }

  enum ranking_period: { not_set: 0, weekly: 1, monthly: 2 }

  # ファイルの種類とサイズのバリデーション（gem ActiveStorage Validationを使用）
  ACCEPTED_CONTENT_TYPES = %w[image/jpeg image/png image/gif image/webp].freeze
  validates :image, content_type: ACCEPTED_CONTENT_TYPES,
                    size: { less_than_or_equal_to: 5.megabytes }

  # 許可するドメインのリスト
  ALLOWED_DOMAINS = [
    "www.youtube.com", "youtube.com", "youtu.be",   # YouTube
    "school.runteq.jp",                             # RUNTEQ
    "www.twitch.tv"                                # Twitch
  ].freeze

  # URLバリデーション
  validates :url, url: { allow_blank: true }, length: { maximum: 2000 }
  validate :validate_url_domain, if: -> { url.present? }

  def self.ransackable_associations(auth_object = nil)
    [ "letter", "letterbox", "user" ]
  end

  def self.ransackable_attributes(auth_object = nil)
    [ "title", "body" ]
  end

  def create_invitation_digest
    self.invitation_token = User.new_token
    update_attribute(:invitation_digest,  User.digest(invitation_token))
    update_attribute(:send_invitation_at, Time.zone.now)
  end

  def invitation_expired?
    send_invitation_at < 3.days.ago
  end

  def authenticated?(invitation_token)
    return false if invitation_digest.nil?
    BCrypt::Password.new(invitation_digest).is_password?(invitation_token)
  end

  def expiration_time
    (send_invitation_at + 3.days).strftime("%Y年%m月%d日 %H:%M")
  end

# 日付範囲を計算するプライベートメソッド
  def calculate_date_range(base_time, period_type)
    return nil unless %w[weekly monthly].include?(period_type)
    base_date = base_time.to_date

    range_config = {
      'weekly' => {
        start: -> (date) { date.beginning_of_week + 5.hours },
        end: -> (date) { date.end_of_week.end_of_day + 5.hours }
      },
      'monthly' => {
        start: -> (date) { date.beginning_of_month + 5.hours },
        end: -> (date) { date.end_of_month.end_of_day + 5.hours }
      }
    }

    # デフォルトは月間
    config = range_config[period_type]
    start_time = config[:start].call(base_date)
    end_time = config[:end].call(base_date)

    start_time..end_time
  end

  # 現在のランキング期間の日付範囲を取得するメソッド
  def current_ranking_date_range
    return nil if not_set?
    calculate_date_range(Time.zone.today, ranking_period)
  end

  # 指定した日付のランキング期間の日付範囲を取得するメソッド
  def ranking_date_range_for(date)
    return nil if not_set?
    calculate_date_range(date, ranking_period)
  end

  # スターランキングを取得するメソッド
  def star_rankings(limit = 10, date_range = current_ranking_date_range)
    return [] if not_set?
    letters
      .where.not(user: nil)
      .where(stared_at: date_range)
      .group(:user)
      .limit(limit)
      .order(Arel.sql('COUNT(star) DESC'))
      .count(:star)
  end

  # 現在のランキング期間の表示用文字列
  def current_ranking_period_display
    date_range = current_ranking_date_range
    start_date = date_range.begin
    end_date = date_range.end

    case ranking_period
    when 'weekly'
      "#{start_date.strftime('%-m/%-d')}～#{end_date.strftime('%-m/%-d')}の週間ランキング"
    when 'monthly'
      "#{start_date.strftime('%-Y年%-m月')}の月間ランキング"
    end
  end

  def cached_star_rankings
    return [] if not_set?
    cache_key = "star_rankings_program_#{id}_#{ranking_period}"
    Rails.cache.fetch(cache_key, expires_in: 60.minutes) do
      star_rankings
    end
  end

  def clear_star_rankings_cache
    cache_key = "star_rankings_program_#{id}_#{ranking_period}"
    Rails.cache.delete(cache_key)
  end

  private

  def validate_url_domain
    uri = URI.parse(url)
    unless ALLOWED_DOMAINS.include?(uri.host)
      errors.add(:url, "このドメインは許可されていません。YouTube、Twitch、RUNTEQイベントページのURLを入力してください。")
    end
  rescue URI::InvalidURIError
    errors.add(:url, "無効なURLの形式です")
  end
end
