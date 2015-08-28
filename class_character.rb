class Character

  attr_reader :id, :movie_id, :actor_id, :name, :movie_title, :actor_name

  def self.get_by_actor_id(actor_id)
    characters = []
    db_connection do |conn|
      characters = conn.exec_params(sql_string_actor_id, [actor_id])
    end
    characters.to_a.map! {|character| Character.new(character)}
  end

  def self.get_by_movie_id(movie_id)
    characters = []
    db_connection do |conn|
      characters = conn.exec_params(sql_string_movie_id, [movie_id])
    end
    characters.to_a.map! {|character| Character.new(character)}
  end

  def initialize (args)
    @id = args["id"].to_i
    @movie_id = args["movie_id"].to_i
    @actor_id = args["actor_id"].to_i
    @name = args["character"]
    @movie_title = args["title"]
    @actor_name = args["name"]
  end
  
################################################################################

  private

  def self.sql_string
    string = "SELECT cast_members.id, cast_members.movie_id, cast_members.actor_id, cast_members.character, "
    string << "movies.title, actors.name "
    string << "FROM cast_members "
    string << "JOIN movies ON movies.id = cast_members.movie_id "
    string << "JOIN actors ON actors.id = cast_members.actor_id "
    string
  end

  def self.sql_string_actor_id
    sql_string << "WHERE cast_members.actor_id = ($1)"
  end

  def self.sql_string_movie_id
    sql_string << "WHERE cast_members.movie_id = ($1)"
  end
end
