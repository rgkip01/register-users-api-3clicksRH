require 'cpf_cnpj'

puts 'Limpando banco de dados...'
User.destroy_all
Address.destroy_all

puts 'Criando usuários e endereços...'

5.times do |i|
  user = User.create!(
    name: "Usuário #{i + 1}",
    email: "usuario#{i + 1}@teste.com",
    document: CPF.generate(false), # Gera um CPF válido sem formatação
    date_of_birth: Date.new(1990 + i, rand(1..12), rand(1..28))
  )

  2.times do |j|
    user.addresses.create!(
      street: "Rua #{j + 1} do Usuário #{i + 1}",
      city: "Cidade #{i + 1}",
      state: "Estado #{i + 1}",
      zip_code: "074112#{i}#{j}",
      country: 'Brasil',
      complement: "Apartamento #{j + 1}"
    )
  end
end

puts 'Seed concluído com sucesso!'
