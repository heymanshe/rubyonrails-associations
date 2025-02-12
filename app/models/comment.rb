class Comment < ApplicationRecord
  include Entryable

  def title
    content.truncate(20)
  end
end
