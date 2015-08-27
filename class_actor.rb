class Actor

  attr_reader :id, :name

  def self.all
    actors = []
    db_connection do |conn|
      actors = conn.exec_params("SELECT id, name FROM actors ORDER BY name")
    end
    actors = actors.to_a.map {|actor| Actor.new(actor)}
    sort_by_name(actors)
  end

  def self.get_by_id(id)
    db_connection do |conn|
      conn.exec_params
    end
  end

  def initialize (args)
    @id = args["id"].to_i
    @name = args["name"]
  end

  def last_name
    names = name.split.reverse
    names.each do |this_name|
      return this_name if this_name[0] =~ /[A-Za-z]/
    end
    names[-1]
  end

  def first_name
    name.split[0]
  end


################################################################################

  private

  def self.sort_by_name (actors)
    actors.sort_by {|actor| [actor.last_name.downcase, actor.first_name]}
  end

end
