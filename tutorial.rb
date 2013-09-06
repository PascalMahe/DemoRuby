require 'sqlite3'

# Create database if needed

# Read file (cf. http://stackoverflow.com/a/7157219/2112089)
str_database_creation = ''
begin
    file = File.open("table_creation.sql", "r")
    while (line = file.gets)
		line = line.strip
        str_database_creation = str_database_creation + line
    end
	puts str_database_creation
	
    file.close
rescue => err
	puts "Exception: #{err}"
end


puts "CREATING DATABASE"
begin
    db = SQLite3::Database.new ("test.db")
	db.execute_batch(str_database_creation)
    
rescue SQLite3::Exception => e 
    puts "Exception occured"
    puts e
ensure
    db.close if db
end