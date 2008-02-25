
class Generator
  @@list = []
  attr_accessor :name, :question, :default_answer

  def initialize(name, question, default_answer = "")
    @@list << self
    @name, @question, @default_answer = name, question, default_answer
  end

  def self.[](name, question, default_answer = "")
    g = new(name, question, default_answer)
  end

  def self.setup
    @@list = generators
  end

  # Collect the names from each generator
  def self.names
    @@list.map { |g| g.name.capitalize }
  end

  def self.generators
    known_generators
  end

  # Runs the script/generate command and extracts generator names from output
  def self.find_generator_names
    []
  end

  def self.known_generators
    [
      Generator["scaffold",   "Name of the model to scaffold:", "User"],
      Generator["controller", "Name the new controller:",       "admin/user_accounts"],
      Generator["model",      "Name the new model:",            "User"],
      Generator["mailer",     "Name the new mailer:",           "Notify"],
      Generator["migration",  "Name the new migration:",        "CreateUserTable"],
      Generator["plugin",     "Name the new plugin:",           "ActsAsPlugin"]
    ]
  end
end
