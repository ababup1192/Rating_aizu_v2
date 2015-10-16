dir=vendor

if [ ! -e $dir ]; then
    bundle install --path vendor/bundle
fi

bundle exec ruby src/main.rb
