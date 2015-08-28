class Movie

  attr_reader :id, :title, :year, :rating, :genre, :studio

  def self.all_with_ordering(order)
    if order == "year"
      self.all(sql_string_year)
    elsif order == "rating"
      self.all(sql_string_rating)
    else
      self.all(sql_string)
    end
  end

  def self.get_by_movie_id(movie_id)
    movie = Movie.new
    db_connection do |conn|
      movie = conn.exec_params(sql_string_by_movie, [movie_id])
    end
    movie = Movie.new(movie[0])
    movie
  end

  def self.get_ordered_chunk(page, order)
    movies = []
    db_connection do |conn|
      movies = conn.exec_params(sql_string_by_chunk(page, order))
    end
    movies = movies.to_a.map {|movie| Movie.new(movie)}
    movies
  end

  def self.find_by_query(query)
    movies = []
    query_like = '%' + query + '%'
    db_connection do |conn|
      movies = conn.exec_params(sql_string_by_query, [query_like, query_like])
    end
    movies = movies.to_a.map {|movie| Movie.new(movie)}
    movies
  end

  def initialize (args = {})
    @id = args["id"].to_i
    @title = args["movie"]
    @year = args["year"].to_i
    if args["rating"]
      @rating = args["rating"].to_i
    else
      @rating = "NO RATING"
    end
    @genre = args["genre"]
    if args["studio"]
      @studio = args["studio"]
    else
      @studio = "NO STUDIO"
    end
  end

################################################################################

  private

  def self.sql_string
    string = "SELECT movies.id, movies.title AS movie, movies.year, movies.rating, "
    string << "genres.name AS genre, studios.name AS studio "
    string << "FROM movies "
    string << "LEFT OUTER JOIN genres ON movies.genre_id = genres.id "
    string << "LEFT OUTER JOIN studios ON movies.studio_id = studios.id"
  end

  def self.sql_string_year
    sql_string << " ORDER BY movies.year"
  end

  def self.sql_string_rating
    sql_string << " ORDER BY movies.rating DESC NULLS LAST"
  end

  def self.sql_string_title
    sql_string << " ORDER BY movies.title"
  end

  def self.sql_string_by_movie
    sql_string << " WHERE movies.id = ($1)"
  end

  def self.sql_string_add_chunk(page)
    offset = (page - 1) * 20
    " LIMIT 20 OFFSET #{offset}"
  end

  def self.sql_string_by_query
    sql_string << " WHERE movies.title ILIKE ($1) OR movies.synopsis LIKE ($2)"
  end

  def self.sql_string_by_chunk(page, order = "")
    search_string = ""
    if order == "year"
      search_string << sql_string_year
    elsif order == "rating"
      search_string << sql_string_rating
    else
      search_string << sql_string_title
    end
    search_string << sql_string_add_chunk(page)
  end

  def self.all(string)
    movies = []
    db_connection do |conn|
      movies = conn.exec_params(string)
    end
    movies = movies.to_a.map {|movie| Movie.new(movie)}
    movies
  end

end
