require 'sinatra'
require 'pg'
require_relative 'class_actor'
require_relative 'class_character'
require_relative 'class_movie'

DBNAME = 'movies'

def db_connection
  begin
    connection = PG.connect(dbname: DBNAME)
    yield(connection)
  ensure
    connection.close
  end
end


get '/' do
  redirect '/actors'
end

get '/actors' do
  page_number = 1
  page_number = params["page"].to_i if params["page"]
  actors = Actor.all
  first_entry = (page_number - 1) * 20
  last_entry = first_entry + 20
  #I realize it's ass-ugly grab all the data from SQL, but I couldn't get pagination, SQL LIMIT/OFFSET,
  #and my own alphabetization sort to talk to each other
  erb :'actors/actors', locals: {actors: actors[first_entry...last_entry], page_number: page_number}
end

get '/actors/:id' do
  characters = Character.get_by_actor_id(params["id"])
  erb :'actors/actor', locals: {characters: characters}
end

get '/movies' do
  page_number = 1
  page_number = params["page"].to_i if params["page"]
  movies = Movie.get_ordered_chunk(page_number, params["order"])
  erb :'movies/movies', locals: {movies: movies, page_number: page_number, order: params["order"]}
end

get '/movies/search' do
  movies = Movie.find_by_query(params["query"])
  erb :'movies/results', locals: {movies: movies}
end

get '/movies/:id' do
  characters = Character.get_by_movie_id(params["id"])
  movie = Movie.get_by_movie_id(params["id"])
  erb :'movies/movie', locals: {characters: characters, movie: movie}
end
