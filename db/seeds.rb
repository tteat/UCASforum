# Dataset
users_count = 20
friends_count = 50

first_names_male = [
    "Data Mining", "The ABC Murders","PRIDE AND PREJUDICE","THE GRAPES OF WRATH","UTRILLO","Je mange ce qui me reussit",
    "CAROL SHIELDS","modern greece","PRACTICAL ETHICS FOR YOU","FOREIGN AFFAIRS","仁成","THE DRY","HURDLING STEEPLECHASING",
    "US AND THEM","THE REVENGE OF GAIA","GHOSTLY ENCOUNI IN SINGAPORE","FALL OF ANGELS","THE BACK OF THE NAPKIN","THE 7 HABITS",
    "CODES OF LOVE","LAPITTURA ITALIANA","HARRY POTTER","CATHETINE COULTER","STATISTICS","THE WASTE LAND"
]

first_names_female = %w[
  动物农庄 计算机体系结构 Linux内核设计 软件工程 大清十二帝 Chrome扩展开发 月亮和六便士 数学之美 C++ 爱与生的苦恼 Java编程思想 史记
  算法讲义 旧山河 无声告白 哲学家们都干了些什么 人间失格 倚天屠龙记 我们仨 白说 活着 你好旧时光 半小时漫画中国史
  目送 我这一辈子
]

first_names = first_names_male + first_names_female

descriptions = [
  '%s这本书生动有趣',
  '%s脑洞很大，值得品读',
  '%s有助于课程的学习',
  '%s故事耐人寻味，引人入胜.',
  '%s讲述了动人心魄的数学故事'

]

# Create users
puts "Creating #{users_count} users..."
User.create!(email: 'test@test', password: 'test@test',
             password_confirmation: 'test@test', first_name: 'Admin',
             phone: '0600000000', is_admin: true)

users = []
users_count.times do
  first_name = first_names.sample
  users << User.create!(email: "#{first_name.parameterize}.#{rand(1..999)}@gmail.com",
                        password: 'test@test',
                        password_confirmation: 'test@test',
                        first_name: first_name,
                        phone: "06#{format('%08d', rand(10**8))}")
end

# Cities
puts 'Creating 4 cities...'
cities = []
cities << City.create!(name: '科技', latitude: 48.86471, longitude: 2.34901)
cities << City.create!(name: '文学', latitude: 45.74846, longitude: 4.84671)
cities << City.create!(name: '生活', latitude: 43.60426, longitude: 1.44367)
cities << City.create!(name: '教材', latitude: 44.83615, longitude: -0.58081)

# Tags
puts 'Creating 15 tags...'
tags = []
tags << Tag.create!(label_male: '搞笑幽默', label_female: '搞笑幽默')
tags << Tag.create!(label_male: '心灵治愈', label_female: '心灵治愈')
tags << Tag.create!(label_male: '名著经典', label_female: '名著经典')
tags << Tag.create!(label_male: '推理悬疑', label_female: '推理悬疑')
tags << Tag.create!(label_male: '人物传记', label_female: '人物传记')
tags << Tag.create!(label_male: '成功励志', label_female: '成功励志')
tags << Tag.create!(label_male: '互联网+', label_female: '互联网+')
tags << Tag.create!(label_male: '青春言情', label_female: '青春言情')
tags << Tag.create!(label_male: '经济管理', label_female: '经济管理')
tags << Tag.create!(label_male: '社交之道', label_female: '社交之道')
tags << Tag.create!(label_male: '心理百科', label_female: '心理百科')
tags << Tag.create!(label_male: '科幻武侠', label_female: '科幻武侠')
tags << Tag.create!(label_male: '美食烹饪', label_female: '美食烹饪')
tags << Tag.create!(label_male: '旅游摄影', label_female: '旅游摄影')
tags << Tag.create!(label_male: '其它', label_female: '其它')

# Friends
puts "Creating #{friends_count} friends, linked to ~#{friends_count * 3} tags..."
friends = []
date_min = Date.new(2000, 12, 12)
date_max = Date.new(1990, 1, 1)
i = 0
friends_count.times do
  i += 1
  male = i <= friends_count / 2
  img = (male ? "male/#{i}" : "female/#{i-25}") + '.jpg'
  first_name = male ? first_names_male[i-1] : first_names_female[i-26]
  date = (date_min + (date_max - date_min) * rand).to_date
  friends << Friend.create!(
    avatar: File.new("#{Rails.root}/app/assets/images/seeds/friends/#{img}"),
    first_name: first_name,
    birthday: date,
    is_male: male,
    description: format(descriptions.sample, first_name),
    city: cities.sample,
    user: users.sample,
    tag_relations_attributes: (tags.sample(rand(2..4)).map { |tag| { tag_id: tag.id } })
  )
end

# Old exchanges
exchanges_created = (friends_count * 0.5 * (1 + 5) / 2).floor
tags_created = exchanges_created * (2 + 5)
puts "Creating ~#{exchanges_created} exchanges"\
     ", linked to ~#{tags_created} tags..."
friends.sample(friends_count * 0.5).each do |friend|
  rand(1..5).times do
    other_friend = friends.sample(20).detect { |other| other.id != friend.id && other.user_id != friend.user_id }
    exchange_old = Exchange.create! is_active: false,
                                    friend_initier_id: friend.id,
                                    friend_receiver_id: other_friend.id

    [friend, other_friend].each do |f|
      tags.sample(rand(2..5)).each do |tag|
        TagRelation.create! exchange: exchange_old, tag: tag, friend: f
      end
    end
  end
end

# Current exchanges
puts "Creating #{(friends.size / 4).floor} active exchanges..."
friends.sample(friends.size / 2).each_slice(2).each do |a, b|
  Exchange.create! is_active: true, friend_initier: a, friend_receiver: b if b and a.user != b.user
end

puts 'Done!'
