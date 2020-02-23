#!/bin/sh

# <bitbar.title>Speedwifi-next W06 transfer amount during 1day</bitbar.title>
# <bitbar.version>1.0.1</bitbar.version>
# <bitbar.author>positrium</bitbar.author>
# <bitbar.author.github>positrium</bitbar.author.github>
# <bitbar.desc>show Speedwifi-next w06 transfer amount during 1day for bitbar.</bitbar.desc>
# <bitbar.image>https://raw.githubusercontent.com/positrium/wifi-transfer-meter/master/image20200122.png</bitbar.image>
# <bitbar.dependencies>ruby >= 2.7.0, gem nokogiri</bitbar.dependencies>
# <bitbar.abouturl>https://github.com/positrium/wifi-transfer-meter</bitbar.abouturl>

RUBY_PATH=$HOME/.anyenv/envs/rbenv/shims/ruby
BITBAR_DIR=$HOME/bitbar_env

$RUBY_PATH $BITBAR_DIR/w06/transfer.rb
