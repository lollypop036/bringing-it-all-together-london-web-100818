class Dog

attr_accessor :name, :breed
attr_reader :id

def attributes

end



def initialize(id:nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
end

def self.create_table
    sql = <<-SQL
    CREATE TABLE dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)
    SQL
    DB[:conn].execute(sql)
end

def self.drop_table
    DB[:conn].execute('DROP TABLE dogs')
end


def save
    if self.id
        self.update
    else
        sql = <<-SQL
        INSERT INTO dogs (name,breed) VALUES (?,?)
        SQL
    DB[:conn].execute(sql, self.name, self.breed)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
end


def self.create(hash)
   dog = self.new(hash)
   dog.save

end


def self.find_by_id(id_no)
    sql = <<-SQL
        SELECT * FROM dogs WHERE id = ?
    SQL
    dog = DB[:conn].execute(sql, id_no)[0]
    new_dog = Dog.new(id:dog[0], name:dog[1], breed:dog[2])
    new_dog
end

def self.find_or_create_by(name:, breed:)
dog = DB[:conn].execute('SELECT * FROM dogs where name = ? AND breed = ?', name, breed)
if !dog.empty?
dog_info = dog[0]
dog =  Dog.new(id:dog_info[0], name:dog_info[1], breed:dog_info[2])
else
    dog = self.create(name: name, breed: breed)
end
dog
end


def self.new_from_db(row)
    dog = Dog.new(id:row[0],name:row[1],breed:row[2])
end

def self.find_by_name(name)
    sql = <<-SQL
        SELECT * FROM dogs where name = ?
    SQL
    dog = DB[:conn].execute(sql, name)[0]
    new_dog = Dog.new(id:dog[0], name:dog[1], breed:dog[2])
    new_dog
end


def update
    sql = <<-SQL
        UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
end


end