--[[Class oluşturma]]
Ball = Class{}

-- CLASS İÇİN STATE OLUŞTURMA / BAŞLANGIÇ DURUMLARI
function Ball:init(x, y, width, height)
    self.x = x
    self.y =y
    self.width = width
    self.height = height

    self.dx = math.random(2) == 1 and 100 or - 100
    self.dy = math.random(-50, 50)
end

-- GÜNCELLEME (LOOP)
function Ball:update(dt)
    self.x = self.x + self.dx * 3 * dt
    self.y = self.y + self.dy * 3 * dt

end

-- ÇARPIŞMA (COLLISION)
function Ball:collides(box)
    -- Burada self.x topumuzun kenarı oluyor ve paddle1 ve paddle2'e göre karşılaştırıyoruz 
    if self.x > box.x + box.width or self.x + self.width < box.x then
        -- Collide olması imkansız çarpışma olmayacak o yüzden false 
        return false
    end
    -- Bu da çarpışmanın ektanın top ve bottom kısımları için
    if self.y > box.y + box.height or self.y + self.height < box.y then
        return false
    end

    return true
end

-- İLK DEĞERE DÖNME
function Ball:reset()
    self.x = VIRTUAL_WIDTH / 2 - 2
    self.y = VIRTUAL_HEIGHT / 2 - 2

    self.dx = math.random(2) == 1 and 100 or - 100
    self.dy = math.random(-50, 50)
end

-- YAZDIRMA (DRRAW())
function Ball:render()
  --[[Ekranımızın tam ortasına topumuzu çiziyoruz 5x5 lik]]
  love.graphics.rectangle('fill', self.x, self.y, 5, 5) 

end
