# Setup do Ambiente com Docker

Este documento fornece instruções detalhadas sobre como subir o ambiente utilizando Docker, rodar testes unitários, executar o linter com RuboCop e listar as requisições da API para Usuários e Endereços.

A Api também foi arquitetada para Serializar os dados e retorna o contrato ao front-end utilizando a [gem fast_jsonapi](https://github.com/Netflix/fast_jsonapi)

## **Requisitos**
Certifique-se de ter instalado:
- [Docker](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04)
- [Docker Compose](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-compose-on-ubuntu-20-04-pt)

## **Subindo o Ambiente com Docker**

1. Clone o repositório:
   ```bash
   git clone git@github.com:rgkip01/register-users-api-3clicksRH.git
   cd register-users-api-3clicksRH
   ```

2. Construa os containers:
   ```bash
   docker-compose build
   ```

3. Crie e migre o banco de dados:
   ```bash
   docker-compose run api bundle exec rails db:create db:migrate
   ```
3.1  Caso queira popular a Base de dados para ter dados existentes no front:
   ```bash
    docker-compose run api bundle exec rails db:seed
   ```
4. Suba os containers:
   ```bash
   docker-compose up
   ```

   O backend estará acessível em `http://localhost:3000` e o frontend em `http://localhost:5173`.

> **Nota:** O ambiente utiliza uma chave `JWT_SECRET` falsa para simular uma chamada autorizada do front com o backend:
>
> ```bash
> JWT_SECRET=eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxfQ.qOC1IujG6MLzDGxrxRIeoo-IPNWwmtZg5tLi8bCguqk
> ```

## **Rodando Testes Unitários**

Para executar os testes unitários do backend, use o seguinte comando:

```bash
docker-compose exec api bundle exec rspec
```

## **Executando o Linter com RuboCop**

Para verificar o código com o linter RuboCop, execute:

```bash
docker-compose exec api bundle exec rubocop
```

Para corrigir automaticamente os problemas detectados pelo RuboCop:

```bash
docker-compose exec api bundle exec rubocop -A
```

## **Lista de Requisições da API**

### **Usuários**

#### **1. Criar Usuário**
- **POST** `/api/v1/users`
- **Body:**
  ```json
  {
    "data": {
      "type": "users",
      "attributes": {
        "name": "João Silva",
        "email": "joao.silva@teste.com",
        "document": "12345678910",
        "date_of_birth": "15/08/1990"
      }
    }
  }
  ```

#### **2. Listar Usuários**
- **GET** `/api/v1/users`
- **Resposta:**
  ```json
  {
    "data": [
      {
        "id": "1",
        "type": "users",
        "attributes": {
          "name": "João Silva",
          "email": "joao.silva@teste.com",
          "document": "12345678910",
          "date_of_birth": "15/08/1990"
        },
        "relationships": {
          "addresses": {
            "data": [
              { "id": "1", "type": "addresses" },
              { "id": "2", "type": "addresses" }
            ]
          }
        }
      }
    ],
    "included": [
      {
        "id": "1",
        "type": "addresses",
        "attributes": {
          "street": "Rua A",
          "city": "Cidade B",
          "state": "Estado C",
          "zip_code": "12345678",
          "country": "Brasil",
          "complement": "Apartamento 101"
        }
      },
      {
        "id": "2",
        "type": "addresses",
        "attributes": {
          "street": "Rua B",
          "city": "Cidade D",
          "state": "Estado E",
          "zip_code": "87654321",
          "country": "Brasil",
          "complement": "Apartamento 202"
        }
      }
    ]
  }
  ```

#### **3. Buscar Usuário por ID**
- **GET** `/api/v1/users/:id`

#### **4. Atualizar Usuário**
- **PUT** `/api/v1/users/:id`
- **Body:**
  ```json
  {
    "data": {
      "type": "users",
      "attributes": {
        "name": "João Silva Atualizado",
        "email": "joao.silva@teste.com",
        "document": "12345678910",
        "date_of_birth": "15/08/1990"
      }
    }
  }
  ```

#### **5. Excluir Usuário**
- **DELETE** `/api/v1/users/:id`

---

### **Endereços**

#### **1. Criar Endereço**
- **POST** `/api/v1/users/:user_id/addresses`
- **Body:**
  ```json
  {
    "data": {
      "type": "addresses",
      "attributes": {
        "street": "Rua A",
        "city": "Cidade B",
        "state": "Estado C",
        "zip_code": "12345678",
        "country": "Brasil",
        "complement": "Apartamento 101"
      }
    }
  }
  ```

#### **2. Listar Endereços de um Usuário**
- **GET** `/api/v1/users/:user_id/addresses`

#### **3. Buscar Endereço por ID**
- **GET** `/api/v1/users/:user_id/addresses/:id`

#### **4. Atualizar Endereço**
- **PUT** `/api/v1/users/:user_id/addresses/:id`
- **Body:**
  ```json
  {
    "data": {
      "type": "addresses",
      "attributes": {
        "street": "Rua A Atualizada",
        "city": "Cidade B",
        "state": "Estado C",
        "zip_code": "12345678",
        "country": "Brasil",
        "complement": "Apartamento 101"
      }
    }
  }
  ```

#### **5. Excluir Endereço**
- **DELETE** `/api/v1/users/:user_id/addresses/:id`

---

## **Explicação sobre o Search**
A API oferece suporte a filtros de busca utilizando os seguintes campos:

- **Nome (`name`)**: O filtro é feito utilizando `ILIKE`, permitindo buscas que não diferenciam maiúsculas e minúsculas.
- **Documento (`document`)**: O filtro é feito utilizando `ILIKE`, aceitando documentos completos ou parciais.
- **Data de Nascimento (`date_of_birth`)**: O filtro é feito utilizando `ILIKE`, aceitando data completa no formato americano (YYYY-MM-DD) ou parcial.

Exemplo de requisição de busca:
```bash
GET /api/v1/users/search?q=1990-08-15
```

---

## **Conclusões Finais:**
Este documento fornece todas as informações necessárias para subir o ambiente, rodar testes, executar o linter e consumir as APIs de Usuários e Endereços.
