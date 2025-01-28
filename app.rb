require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'bcrypt'

enable :sessions

before do
  protected_routes = ['/projekt', '/skapa']
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

  db = SQLite3::Database.new('db/losen.db')
  db.execute('INSERT INTO scheman (flat_press_variation,incline_press_variation,fly_variation,shoulder_press_variation,later_raise_variation,rear_delt_cariation,tricep_compound,single_arm_extension) VALUES (?,?,?,?,?,?,?,?)',[flat_press_variation,incline_press_variation,fly_variation,shoulder_press_variation,later_raise_variation,rear_delt_cariation,tricep_compound,single_arm_extension])
  redirect('/skapa')
end

get('/profil') do
  slim(:se_profil)
end