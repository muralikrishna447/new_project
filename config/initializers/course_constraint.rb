class CourseConstraint
  def self.matches?(request)
    ['/courses','/courses/science-of-poutine','/courses/knife-sharpening','/courses/accelerated-sous-vide-cooking-course'].include?(request.path)
  end
end