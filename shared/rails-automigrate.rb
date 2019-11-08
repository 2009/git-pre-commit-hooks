#!/usr/bin/env ruby

# Source: https://gist.github.com/icem/6154863

# To install run:
#   chmod +x git-hooks/pending_migrations_check.rb
#   cd .git/hooks
#   ln -is ../../git-hooks/pending_migrations_check.rb post-merge
#   ln -is ../../git-hooks/pending_migrations_check.rb post-checkout
#
# This script checks if there was new migrations after git pull (by rebase too), git checkout.
# Default behaviour is simple warning, to run migrations automatically specify it in .git/config.
# Example of .git/config
#  [rails]
#    automigrate = true
#    automigrateforegroundcolor = yellow
#    automigratebackgroundcolor = black

COLOR_MAPPINGS = {black: 0,
                  red: 1,
                  green: 2,
                  yellow: 3,
                  blue: 4,
                  magenta: 5,
                  cyan: 6,
                  white: 7}

def console_color(color, default)
  COLOR_MAPPINGS[color.to_s.downcase.gsub("\n", '').to_sym] || COLOR_MAPPINGS[default]
end

def puts_colored(text)
  @fg_color ||= console_color(`git config rails.automigrateforegroundcolor`, :yellow)
  @bg_color ||= console_color(`git config rails.automigratebackgroundcolor`, :black)
  puts "\e[0;1;3#{@fg_color};4#{@bg_color}m#{text}\e[0m"
end

if `git diff --name-only HEAD@{1} HEAD`.index('db/migrate')
  automigrate = `git config rails.automigrate`.index('true')
  if automigrate
    puts_colored('Migrating Database... Please wait.')
    `rake db:migrate db:test:prepare`
    puts_colored('Done migrating database.')
  else
    puts_colored('There are pending migrations.')
  end
end
