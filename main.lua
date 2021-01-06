--[[Bu şekilde yorum yapılıyor!]]
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

--[[Şimdi ekrandaki yazımızı büyütmek için 16:9 boyutu kullanalım]]
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

--[[Paddle'laırn bir başlangıç hızı olsun]]
PADDLE_SPEED = 200

--[[En üst kısma Class library'i import ediyoruz ki order'a göre diğer alanlar da etkilensin]]
Class = require 'class'

--[[PUSH library'yi import edebilmek için]]
push = require 'push'

--[[Burada Ball.lua'yı import ediyoruz]]
require 'Ball'

--[[Ve Paddle'ı import ediyoruz]]
require 'Paddle'

--[[Padlle'lar hareket ederken Y ekseninde edecek ve 2 paddle var bunları tanımlayalım]]
paddle1 = Paddle(5, 20, 5, 20)
paddle2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

-- ball' un tanımlanması
ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 5 , 5)

-- Servis'in sırası kimde onu bulabilmek için servis değişkeni belirliyoruz 1.oyuncu ise "1", 2. oyuncu ise "2" değeri vericez!
servingPlayer = math.random(2) == 1 and 1 or 2

-- Öncelikle kontrol ediyoruz servigPlayer sonuçlarımızı
if servingPlayer == 1 then
  ball.dx = 100
else 
  ball.dx = -100
end

-- Kazanan oyuncu en başta kimse olmadığı için sıfıra eşitliyoruz!
winningPlayer = 0

--[[Ekranı yüklemek için]]
function love.load()
  --[[push kullandığımız için window kodumuz değişti]]
  --[[love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
    fullscreen = false,
    vsync = true,
    resizable = false
  })]]

  -- Title of the Game
  love.window.setTitle("Pong")
  
  --[[Topumuza random yön sağlıyoruz]]
  math.randomseed(os.time())

  --[[Scorelar için değişkenlerimizi sayaç şeklinde oluşturalım]]
  player1Score = 0
  player2Score = 0

  --[[Oyunumuz için 2 tane state oluşturmamız gerekiyor birisi start birisi play için bu start]]
  gameState = 'start'

  --[[Sonucumuzun blurluğunu daha net hale getirmek için love.graphics.setDefaultFilter("nearest", "nearest") kullanıyoruz.]]
  love.graphics.setDefaultFilter('nearest', 'nearest') --[[Bu kod ile daha net bir yazı elimizde oluyor]]

  --[[Yeni  bir font'u sadece import etme ve size verme]]
  smallFont = love.graphics.newFont('font1.TTF', 8)

  --[[Score lar için yeni bir font oluşturalım]]
  scoreFont = love.graphics.newFont('font1.ttf', 32)

  -- Kazananı gösteren fontu oluşturmalıyız
  victoryFont = love.graphics.newFont("font1.ttf", 24)

  -- Audio seslerini programa dahil edelim ve bir object oluşturalım
  sounds = {
    ['paddle_hit'] = love.audio.newSource('paddle_hit.wav', 'static'),
    ['wall_hit'] = love.audio.newSource('wall_hit.wav', 'static'),
    ['point_scored'] = love.audio.newSource('point_scored.wav', 'static')
  }

  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
    fullscreen = false,
    vsync = true,
    resizable = false
  })
end

function love.update(dt)
  paddle1:update(dt)
  paddle2:update(dt)
  
  if gameState == "play" then
    -- Score Incrementation Yan duvarlara değince score değişsin!
    -- For the Right Score 
    if ball.x <= 0 then
      player2Score = player2Score + 1
      servingPlayer = 1
      sounds['point_scored']:play()
      ball:reset()
      if player2Score >= 3 then
        gameState = 'victory'
        winningPlayer = 2
      else
        gameState = 'serve'
      end
      ball.dx = 100
    end

    -- For the left score
    if ball.x >= VIRTUAL_WIDTH - 5 then
      player1Score = player1Score + 1
      servingPlayer = 2
      sounds['point_scored']:play()
      ball:reset()
      if player1Score >= 3 then
        gameState = 'victory'
        winningPlayer = 1
      else
        gameState = 'serve'
      end
      ball.dx = -100
    end

    -- Eğer topumuz paddle'a çarparsa yön değiştirsin
    if ball:collides(paddle1) then
      -- Soldakine çarparsa ters yöne gitsin
      sounds['paddle_hit']:play()
      ball.dx = -ball.dx
    end 

    if ball:collides(paddle2) then
      -- Sağdakine çarparsa yine yön değiştirsin
      sounds['paddle_hit']:play()
      ball.dx = -ball.dx 
    end

    if ball.y <= 0 then
      -- Yukarı çarpınca aşağıya dönsün
      ball.dy = -ball.dy
      ball.y = 0
      sounds['wall_hit']:play()
    end

    if ball.y >= VIRTUAL_HEIGHT - 5 then
      -- Buradaki 5 değer topumuzun yüksekliği, şimdi aşağıdan döndürmek için yapalım
      ball.dy = -ball.dy
      ball.y = VIRTUAL_HEIGHT - 5
      sounds['wall_hit']:play()
    end
  end
  --[[Eğer W basarsa yukarı S basarsa aşağı hareket etsin player 1]]
  if love.keyboard.isDown('w') then
    paddle1.dy = -PADDLE_SPEED

  elseif love.keyboard.isDown('s') then
    paddle1.dy = PADDLE_SPEED

  else 
    paddle1.dy = 0
  end

  --[[Eğer UP a basarsa yukarı, DOWN a basarsa aşağı hareket etsin player 2]]
  if love.keyboard.isDown('up') then
    paddle2.dy = -PADDLE_SPEED
  
  elseif love.keyboard.isDown('down') then
    paddle2.dy = PADDLE_SPEED

  else  
    paddle2.dy = 0
  end

  -- Addition of AI to the second paddle for the atuomatical moving based on the direction of the ball
  if paddle2.y > ball.y then 
    paddle2.y = paddle2.y - (PADDLE_SPEED * 0.5 * dt) 
  end 

  if  paddle2.y < ball.y then
    paddle2.y = paddle2.y + (PADDLE_SPEED * 0.5 * dt) 
  end

  --[[gameState'i burada update ederek aslında oyunu başlatmış oluyoruz. 'play' ile başlasın]]
  if gameState == 'play' then

    ball:update(dt)
  end
end

--[[Eğer oyunumuzu açmışken "Escape" tuşuna basarsak ekranı kapatısn!]]
function love.keypressed(key)
  if key == "escape" then
    love.event.quit()

  elseif key == "enter" or key == "return" then
    if gameState == 'start' then
      gameState = 'serve'
    
    -- Kazanan varsa en başa dönsün
    elseif gameState == 'victory' then
      gameState = 'start'
      player1Score = 0
      player2Score = 0
    elseif gameState == 'serve' then
      gameState = 'play'
    end
  end
end  


--[[Ekrana yazdırmak için]]
function love.draw()
  --[[Virtual resolution'da yazdırmaya başlama]]
  push:apply('start')

  --[[Background - color ı ayarlamak için clear yapıyoruz]]
  love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)


  --[[Daha localized bir yazı için buraya koyduk]]
  love.graphics.setFont(smallFont)

  -- [[Oyunun başlangıcı oyun içi ve sonrası için mesajlar ekleyelim]]
  if gameState == 'start' then
    love.graphics.printf("Welcome to Pong", 0, 20, VIRTUAL_WIDTH, 'center')
    love.graphics.printf("Press Enter to Play!", 0, 32, VIRTUAL_WIDTH, 'center')
  elseif gameState == 'serve' then
    love.graphics.printf("Player" .. tostring(servingPlayer) .. "'s turn!", 0, 20, VIRTUAL_WIDTH, 'center')
    love.graphics.printf("Press Enter to Play!", 0, 32, VIRTUAL_WIDTH, 'center')  
  -- Oyunculardan birinin kazanması durumunda
  elseif gameState == 'victory' then
    love.graphics.setFont(victoryFont)
    love.graphics.printf("Player " .. tostring(winningPlayer) .. " wins!", 0, 10, VIRTUAL_WIDTH, 'center')
  -- victoryFont u 24 px yapıcaz 8px de yazımızın boyutu var en az 32px olması ve boşluk koymamız lazım 42px yapalım
    love.graphics.setFont(smallFont)   -- Victory yazısından sonraki yazı küçük olsun diye
    love.graphics.printf("Press Enter to serve!", 0, 42, VIRTUAL_WIDTH, 'center')
  elseif gameState == 'play' then
    -- buraya bir mesaj gelmesin 
  end

  
  --[[Dinamik olarak paddlelarımızı draw edebilmek için Paddle.lua dan çekiyoruz.]]
  paddle1:render()
  paddle2:render()

  --[[Ball u draw edebililmek için]]
  ball:render()

  --[[Score'ların boyutu ve fontu için]]
  love.graphics.setFont(scoreFont)
  --[[Ekrana scoreları yazdırmak için]]
  love.graphics.print(player1Score, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
  love.graphics.print(player2Score, VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)

  --[[Virtual resolution'da yazdırmayı bitirme]]

  --[[FPS'i göstermek için buraya fonksiyonumuzu çağırıyoruz fakat bu func henüz oluşturulmadığı için draw dışında oluşturuyoruz]]
  displayFPS()

  push:apply('end')
end

--[[Bu fonksiyonda timer bir integer döndürüyor ve FPS string ile integer ".." operatörüyle concat olmuyor çünkü sadece string
olanları concat ediyor bu nedenle timerdan gelen sonucu tostring ile string'e çeviriyoruz.]]
function displayFPS()
  love.graphics.setColor(0, 1, 0 , 1) --[[r, g, b, a olduğu için ona göre bir düzenleme]]
  love.graphics.setFont(smallFont)    --[[Font u globalden çekiyoruz import etmiştik zaten]]
  love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 40, 20) 
  love.graphics.setColor(1, 1, 1, 1)   --[[Geriye kalan herşeyi tekrardan beyaz yapmak için]]
end 