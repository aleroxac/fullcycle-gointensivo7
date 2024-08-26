import json
import requests

# Autenticação
initial_auth = ('admin', 'admin')
dev_auth = ('dev', 'sonar')

# Criar um novo usuário "newuser" com senha "sonar" e perfil de administrador
user_creation_data = {
    'login': 'dev',
    'name': 'dev',
    'password': 'sonar',
    'password_confirmation': 'sonar',
    'email': 'dev@fullcycle.com.br',
    'scm_account': 'dev',
    'groups': 'sonar-administrators'
}
requests.post('http://localhost:9000/api/users/create', auth=initial_auth, data=user_creation_data)


# Criar o projeto
project_creation_data = {
    'name': 'gobook',
    'project': 'gobook',
    'visibility': 'public'
}
response = requests.post('http://localhost:9000/api/projects/create', auth=dev_auth, data=project_creation_data)
project_key = response.json()['project']['key']

# Criar o token
token_creation_data = {
    'name': f'{user_creation_data["login"]}-token',
    'login': user_creation_data["login"],
    'scopes': 'project:' + project_key
}
response = requests.post('http://localhost:9000/api/user_tokens/generate', auth=dev_auth, data=token_creation_data)
token = response.json()['token']

# Montar a resposta no formato JSON
response_data = {
    'project_url': f'http://localhost:9000/dashboard?id={project_key}',
    'token': token,
    'user': 'dev',
    'pass': 'sonar'

}
print(json.dumps(response_data))
