require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'bcrypt'

enable :sessions

before do
  protected_routes = ['/projekt', '/skapa', '/profil']
  if protected_routes.include?(request.path_info) && !session[:id]
    redirect('/')
  end
end

get('/showlogin') do
  slim(:login)
end

get('/') do
  slim(:register)
end

post('/login') do
  username = params[:username]
  password = params[:password] 
  db = SQLite3::Database.new('db/losen.db')
  db.results_as_hash = true 
  result = db.execute("SELECT * FROM users WHERE username = ?", [username]).first
  pwdigest = result["pwdigest"]
  id = result["id"]

  if BCrypt::Password.new(pwdigest) == password 
    session[:id] = id
    redirect('/skapa')
  else
    "FEL LÖSEN!"
  end

end

get('/projekt') do
  id = session[:id].to_i
  db = SQLite3::Database.new('db/losen.db')
  db.results_as_hash = true 
  result = db.execute("SELECT * FROM projekt WHERE user_id = ?",id)
  p "Alla projekt från result #{result}"
  slim(:'projekt/index', locals:{projekt:result})
end

post('/users/new') do 
  username = params[:username]
  password = params[:password]
  password_confirm = params[:password_confirm]
  title = params[:title]

  if (password == password_confirm)
    password_digest = BCrypt::Password.create(password)
    db = SQLite3::Database.new('db/losen.db')
    db.execute('INSERT INTO users (username,pwdigest,title) VALUES (?,?,?)',[username,password_digest,title])
    redirect('/showlogin')
  else
    "Lösenorden matchade inte"
  end
end

get('/skapa') do
  slim(:pass_skapare)
end

post('/pass_skapare') do 
  flat_press_variation = params[:flat_press_variation]
  incline_press_variation = params[:incline_press_variation]
  fly_variation = params[:fly_variation]
  shoulder_press_variation = params[:shoulder_press_variation]
  later_raise_variation = params[:later_raise_variation]
  rear_delt_cariation = params[:rear_delt_cariation]
  tricep_compound = params[:tricep_compound]
  single_arm_extension = params[:single_arm_extension]

  exercise_difficulty = {
    "Bench press" => 2, "chest press" => 1, "flat dumbell press" => 3,
    "incline bench press" => 2, "incline chest press" => 1, "incline dumbell press" => 3,
    "pec deck fly" => 1, "cable fly" => 2, "dumbell fly" => 3,
    "smith shoulder press" => 1, "dumbell shoulder press" => 2, "machine shoulder press" => 3,
    "dumbell lateral raise" => 1, "cable lateral raise" => 2, "machine lateral raise" => 3,
    "reverse fly" => 1, "face pulls" => 2, "cable reverse fly" => 3,
    "dips" => 3, "tricep pushdown" => 1, "cable tricep extension" => 2,
    "single arm extension" => 1, "carter extension" => 2, "katana extension" => 3
  }

  total_difficulty = 
  exercise_difficulty[flat_press_variation] +
  exercise_difficulty[incline_press_variation] +
  exercise_difficulty[fly_variation] +
  exercise_difficulty[shoulder_press_variation] +
  exercise_difficulty[later_raise_variation] +
  exercise_difficulty[rear_delt_cariation] +
  exercise_difficulty[tricep_compound] +
  exercise_difficulty[single_arm_extension]

  db = SQLite3::Database.new('db/losen.db')
  db.execute('INSERT INTO scheman (flat_press_variation,incline_press_variation,fly_variation,shoulder_press_variation,later_raise_variation,rear_delt_cariation,tricep_compound,single_arm_extension,difficulty) VALUES (?,?,?,?,?,?,?,?,?)',[flat_press_variation,incline_press_variation,fly_variation,shoulder_press_variation,later_raise_variation,rear_delt_cariation,tricep_compound,single_arm_extension,total_difficulty])
  redirect('/skapa')
end

get('/profil') do
  slim(:se_profil)
end