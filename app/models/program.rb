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
