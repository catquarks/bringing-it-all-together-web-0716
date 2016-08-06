class Dog

	attr_accessor :name, :breed
	attr_reader :id

	def initialize(attributes = {id: nil})
		@id, @name, @breed = attributes[:id], attributes[:name], attributes[:breed]
	end

	def self.create_table
		sql = <<-SQL
			CREATE TABLE IF NOT EXISTS dogs (
			id INTEGER PRIMARY KEY,
			name TEXT,
			breed TEXT)
		SQL
		DB[:conn].execute(sql)
	end

	def self.drop_table
		DB[:conn].execute('DROP TABLE dogs')
	end

	def save
		sql = 'INSERT INTO dogs (name, breed) VALUES (?, ?)'
		DB[:conn].execute(sql, self.name, self.breed)
		sql = 'SELECT last_insert_rowid() FROM dogs'
		@id = DB[:conn].execute(sql)[0][0]
		attributes = {id:@id, name:self.name, breed:self.breed}
		self.class.new(attributes)
	end

	def update
		sql = 'UPDATE dogs SET name = ?, breed = ? WHERE id = ?'
		DB[:conn].execute(sql, self.name, self.breed, self.id)
	end

	def self.create(attributes = {})
		dog = self.new(attributes)
		dog.save
	end

	def self.find_by_id(id)
		sql = 'SELECT * FROM dogs WHERE id = ?'
		results = DB[:conn].execute(sql, id)[0]
		attributes = {id: results[0], name: results[1], breed:results[2]}
		self.new(attributes)
	end

	def self.find_by_name(name)
		sql = 'SELECT * FROM dogs WHERE name = ?'
		results = DB[:conn].execute(sql, name)[0]
		attributes = {id: results[0], name: results[1], breed:results[2]}
			self.new(attributes)
	end

	def self.new_from_db(row)
		attributes = {id: row[0], name: row[1], breed: row[2]}
		self.new(attributes)
	end

	def self.find_or_create_by(attributes = {})
		sql = 'SELECT * FROM dogs WHERE name = ? AND breed = ?'
		results = DB[:conn].execute(sql, attributes[:name], attributes[:breed])[0]
		if results
			attributes[:id] = results[0]
			self.new(attributes)
		else
			self.create(attributes)
		end
	end

end