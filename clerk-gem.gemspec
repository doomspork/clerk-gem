Gem::Specification.new do |s|
  s.name        = 'clerk-gem'
  s.version     = '0.1.0'
  s.date        = '2013-05-29'
  s.authors     = ['Sean Callan', 'Jeff Carouth']
  s.email       = ['callan@liftopia.com', 'jeff@liftopia.com']
  s.summary     = 'Clerk helps turn data into a structured, verified, and transformed collection.'
  s.license     = 'MIT'
  s.files       = ['lib/clerk.rb']
  s.add_dependency('activemodel', '~> 3.2.13')
end
