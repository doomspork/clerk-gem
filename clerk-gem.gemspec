Gem::Specification.new do |s|
  s.name        = 'clerk-gem'
  s.version     = '0.2.0'
  s.date        = '2016-04-01'
  s.authors     = ['Liftopia Engineering']
  s.email       = ['info@liftopia.com']
  s.summary     = 'Clerk helps turn data into a structured, verified, and transformed collection.'
  s.license     = 'MIT'
  s.files       = ['lib/clerk.rb']
  s.add_dependency('activemodel', '>= 4.0.13')
end
