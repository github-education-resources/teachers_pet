# More info at https://github.com/guard/guard#readme

guard :rspec, all_on_start: true, cmd: 'bundle exec rspec' do
  watch(%r{^lib/.*}) { 'spec' }
  watch(%r{^spec/.*})
  watch('spec/spec_helper') { 'spec' }
end
