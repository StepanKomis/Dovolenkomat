VacationRequest.destroy_all
Setting.destroy_all
User.destroy_all

PASSWORD = "password123"

boss = User.create!(name: "Karel Novák", email: "boss@dovolenkomat.cz", password: PASSWORD, role: :head)

hr1 = User.create!(name: "Jana Svobodová", email: "hr1@dovolenkomat.cz", password: PASSWORD, role: :hr)
hr2 = User.create!(name: "Petr Dvořák", email: "hr2@dovolenkomat.cz", password: PASSWORD, role: :hr)

employees = [
  User.create!(name: "Lucie Malá", email: "lucie@dovolenkomat.cz", password: PASSWORD, role: :employee),
  User.create!(name: "Tomáš Král", email: "tomas@dovolenkomat.cz", password: PASSWORD, role: :employee),
  User.create!(name: "Eva Horáková", email: "eva@dovolenkomat.cz", password: PASSWORD, role: :employee),
  User.create!(name: "Martin Procházka", email: "martin@dovolenkomat.cz", password: PASSWORD, role: :employee),
]

Setting.create!(max_concurrent_vacationers: 2, updated_by: boss)

# pending - just submitted, nobody decided yet
VacationRequest.create!(
  user: employees[0],
  start_date: Date.new(2026, 8, 3),
  end_date: Date.new(2026, 8, 10),
  reason: "Family vacation"
)

# hr_approved - HR said yes, waiting on head
VacationRequest.create!(
  user: employees[1],
  start_date: Date.new(2026, 7, 20),
  end_date: Date.new(2026, 7, 24),
  reason: "Wedding",
  hr_status: :approved, hr_decided_by: hr1, hr_decided_at: 2.days.ago
)

# approved - both HR and head said yes
VacationRequest.create!(
  user: employees[2],
  start_date: Date.new(2026, 9, 1),
  end_date: Date.new(2026, 9, 5),
  reason: "Trip abroad",
  hr_status: :approved, hr_decided_by: hr2, hr_decided_at: 5.days.ago,
  head_status: :approved, head_decided_by: boss, head_decided_at: 4.days.ago
)

# rejected by HR
VacationRequest.create!(
  user: employees[3],
  start_date: Date.new(2026, 7, 15),
  end_date: Date.new(2026, 7, 16),
  reason: "Short trip during a busy period",
  hr_status: :rejected, hr_decided_by: hr1, hr_decided_at: 1.day.ago,
  hr_comment: "Too close to the product launch"
)

# rejected by head, after HR already approved
VacationRequest.create!(
  user: employees[0],
  start_date: Date.new(2026, 12, 22),
  end_date: Date.new(2027, 1, 2),
  reason: "Christmas holidays",
  hr_status: :approved, hr_decided_by: hr2, hr_decided_at: 3.days.ago,
  head_status: :rejected, head_decided_by: boss, head_decided_at: 2.days.ago,
  head_comment: "Whole team is out that week already"
)

# HR self-approval - HR requesting their own vacation skips peer HR review
VacationRequest.create!(
  user: hr1,
  start_date: Date.new(2026, 11, 2),
  end_date: Date.new(2026, 11, 6),
  reason: "Personal time off",
  hr_status: :approved, hr_decided_by: hr1, hr_decided_at: Time.current,
  hr_comment: "Self-approved (hr)"
)

# head self-approval - fully approved instantly
VacationRequest.create!(
  user: boss,
  start_date: Date.new(2026, 8, 17),
  end_date: Date.new(2026, 8, 21),
  reason: "Boss's own vacation",
  hr_status: :approved, hr_decided_by: boss, hr_decided_at: Time.current,
  hr_comment: "Self-approved (head)",
  head_status: :approved, head_decided_by: boss, head_decided_at: Time.current,
  head_comment: "Self-approved (head)"
)

# a second pending request, so HR/head have something fresh to act on in a demo
VacationRequest.create!(
  user: employees[2],
  start_date: Date.new(2026, 10, 12),
  end_date: Date.new(2026, 10, 16),
  reason: "Long weekend"
)

puts "Seeded #{User.count} users, #{VacationRequest.count} vacation requests, " \
     "max_concurrent_vacationers=#{Setting.current.max_concurrent_vacationers}."
puts "All passwords: #{PASSWORD}"
puts "  head:     #{boss.email}"
puts "  hr:       #{hr1.email}, #{hr2.email}"
puts "  employee: #{employees.map(&:email).join(', ')}"
