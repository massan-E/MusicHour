# frozen_string_literal: true

# Active Storage / image_processing は libvips (ruby-vips) を使って画像を処理する。
# 信頼できないアップロード画像を libvips が処理する経路の RCE
# (Active Storage の画像処理に関する CVE) に対する多層防御として、
# libvips の untrusted なローダー/オペレーションをブロックする。
#
# これにより一般的な形式 (JPEG/PNG/WebP/GIF 等) の読み込みは維持したまま、
# 攻撃に悪用されやすいマイナー/危険な形式の処理を無効化する。
#
# 必要要件: libvips >= 8.13, ruby-vips >= 2.2.1
require "vips"

Vips.block_untrusted(true) if Vips.respond_to?(:block_untrusted)
