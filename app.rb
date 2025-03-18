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

  if result && BCrypt::Password.new(result["pwdigest"]) == password
    session[:id] = result["id"]
    session[:username] = result["username"]  
    session[:title] = result["title"]        
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
  result = db.execute("SELECT * FROM projekt WHERE title = ?",title)
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
  db = SQLite3::Database.new('db/losen.db')
  db.results_as_hash = true

  flat_press_variation = params[:flat_press_variation]
  incline_press_variation = params[:incline_press_variation]
  fly_variation = params[:fly_variation]
  shoulder_press_variation = params[:shoulder_press_variation]
  later_raise_variation = params[:later_raise_variation]
  rear_delt_variation = params[:rear_delt_variation]
  tricep_compound = params[:tricep_compound]
  single_arm_extension = params[:single_arm_extension]

  frontal_pull = params[:frontal_pull]
  transversal_row = params[:transversal_row]
  sagital_pull = params[:sagital_pull]
  curl_variation = params[:curl_variation]
  hammer_curl_var = params[:hammer_curl_var]

  quad_com = params[:quad_com]
  leg_ext = params[:leg_ext]
  hinge = params[:hinge]
  leg_curl = params[:leg_curl]
  abbductor = params[:abbductor]
  calf_raise = params[:calf_raise]
  abs = params[:abs]

  exercise_difficulty = {
    "Bench press" => 2, "chest press" => 1, "flat dumbell press" => 3,
    "incline bench press" => 2, "incline chest press" => 1, "incline dumbell press" => 3,
    "pec deck fly" => 1, "cable fly" => 2, "dumbell fly" => 3,
    "smith shoulder press" => 2, "dumbell shoulder press" => 3, "machine shoulder press" => 1,
    "dumbell lateral raise" => 2, "cable lateral raise" => 3, "machine lateral raise" => 1,
    "reverse fly" => 1, "face pulls" => 2, "cable reverse fly" => 3,
    "dips" => 2, "tricep pushdown" => 1, "cable tricep extension" => 3,
    "single arm extension" => 1, "carter extension" => 2, "katana extension" => 3,

    "lat_pulldown" => 1, "pull_up" => 3, "singel_hand_lat_pulldown" => 2,
    "T-bar_row" => 1, "wide_grip_cable_row" => 3, "chest_supported_wide_grip_row" => 2,
    "close_grip_row" => 1, "jpg_pulldown" => 2, "pull_overs" => 3,
    "preacher curl" => 3, "dumbell curl" => 1, "barbell curl" => 2,
    "hammer curl" => 1, "cable hammer curl" => 2, "preacher hammer curl" => 3,

    "leg press" => 1, "squats" => 3, "hack squat" => 2,
    "leg extension" => 1, "single lex extension" => 2,
    "barbell Romanian deadlift" => 3, "dumbell romanian deadlift" => 1, "cable romanian deadlift" => 2,
    "seated leg curl" => 1, "laying leg curl" => 2,
    "abbductor machine" => 1,
    "standing calf raise" => 2, "seated calf raise" => 1, "leg press calf raise" => 3,
    "cable crunch" => 2, "sit ups" => 1, "roller" => 3
  }

  difficulty_push = [
    flat_press_variation, incline_press_variation, fly_variation, shoulder_press_variation,
    later_raise_variation, rear_delt_variation, tricep_compound, single_arm_extension
  ].compact.map { |exercise| exercise_difficulty[exercise] || 0 }.sum

  difficulty_pull = [
    frontal_pull, transversal_row, sagital_pull, curl_variation, hammer_curl_var
  ].compact.map { |exercise| exercise_difficulty[exercise] || 0 }.sum

  difficulty_legs = [
    quad_com, leg_ext, hinge, leg_curl, abbductor, calf_raise, abs
  ].compact.map { |exercise| exercise_difficulty[exercise] || 0 }.sum

  db.execute('INSERT INTO scheman 
  (user_id, flat_press_variation, incline_press_variation, fly_variation, shoulder_press_variation, later_raise_variation, rear_delt_variation, tricep_compound, single_arm_extension, 
  frontal_pull, transversal_row, sagital_pull, curl_variation, hammer_curl_var,
  quad_com, leg_ext, hinge, leg_curl, abbductor, calf_raise, abs, difficulty_push, difficulty_pull, difficulty_legs) 
  VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', 
  [session[:id], flat_press_variation, incline_press_variation, fly_variation, shoulder_press_variation, later_raise_variation, rear_delt_variation, tricep_compound, single_arm_extension,
  frontal_pull, transversal_row, sagital_pull, curl_variation, hammer_curl_var,
  quad_com, leg_ext, hinge, leg_curl, abbductor, calf_raise, abs, difficulty_push, difficulty_pull, difficulty_legs])

  redirect('/skapa')
end



get('/profil') do
  slim(:se_profil)
end

get('/logout') do
  session.clear  
  redirect('/showlogin')
end

get('/mina_pass') do
  id = session[:id]
  db = SQLite3::Database.new('db/losen.db')
  db.results_as_hash = true
  result = db.execute("SELECT * FROM scheman WHERE user_id = ?", [id])
  
  slim(:mina_pass, locals: { pass: result })
end
