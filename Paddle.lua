--[[Boş  bir Class oluşturup Paddle değişkenine assign ediyoruz]]
Paddle = Class{}

--[[Class'ımızı ve state'imizi tanımlıyoruz bu fonksiyonda Paddle değişkeninde bunun bir class olduğu bilgisini alıyor]]
function Paddle:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    --[[Normalde dy değerimiz başlangıçta olmadığı için sıfır atıyoruz.]]
    self.dy = 0
end

--[[Şimdi bir update funtion'ımızı buraya oluşturalım burada player1Y/2y self.y'a dönüşüyor]]
function Paddle:update(dt)
    if self.dy < 0 then 
        self.y = math.max(0, self.y + self.dy * dt)
    elseif self.dy > 0 then
        self.y = math.min(VIRTUAL_HEIGHT - 20, self.y + self.dy * dt)
    end
end

--[[Her bir paddle için rectangle'ı tek tek yazmak yerine render fonksiyonu oluşturuyoruz]]
function Paddle:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end    
