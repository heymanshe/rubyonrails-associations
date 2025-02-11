class Student < ApplicationRecord
  belongs_to :teacher, optional: true
end
