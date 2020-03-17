class String
  def normalize_newlines
  	encode(encoding, universal_newline: true)
  end
end