class Dog
    
    attr_accessor :id, :name, :breed
    
    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed 
    end

    def self.create_table
        DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT);")
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed) 
            VALUES (?,?);
        SQL
        
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0] 
        
        self
    end

    def self.create(hash_of_attributes)
        new_dog = self.new(hash_of_attributes)
        new_dog.save
    end

    def self.new_from_db(row)
        attributes_hash = {
        :id => row[0],
        :name => row[1],
        :breed => row[2]
        }
        new_dog = self.new(attributes_hash)
        new_dog
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * 
            FROM dogs
            WHERE id = ?
        SQL
        DB[:conn].execute(sql, id).map do |row|
			self.new_from_db(row)
        end.first
	end
	
	def self.find_or_create_by(name:, breed:)
        sql = <<-SQL 
            SELECT * 
            FROM dogs 
            WHERE name = ? AND breed = ?
        SQL
       dog = DB[:conn].execute(sql,name,breed).first
       #binding.pry
        if dog 
            new_dog = self.new_from_db(dog)
        else
            new_dog = self.create(name: name, breed: breed)
        end
        new_dog
    end
    
    def self.find_by_name(name)
    sql = <<-SQL 
        SELECT * 
        FROM dogs 
        WHERE name = ?
        
    SQL
    DB[:conn].execute(sql, name).map do |row|
        self.new_from_db(row)
        end.first
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end


end