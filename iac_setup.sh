#!/bin/bash
#
# iac_setup.sh - Provisionamento de usuários, grupos e permissões no Linux
#
# Cria a estrutura de pastas de uma empresa fictícia, os grupos por
# departamento e os usuários, aplicando RBAC e o princípio do menor privilégio.
#
# Uso: sudo ./iac_setup.sh

set -euo pipefail

# Senha inicial de laboratório. Cada usuário é obrigado a trocá-la no primeiro login.
SENHA_INICIAL="Senha123"

if [[ $EUID -ne 0 ]]; then
    echo "Erro: execute este script como root (sudo ./iac_setup.sh)." >&2
    exit 1
fi

echo "Iniciando o provisionamento de infraestrutura..."

echo "1. Criando diretórios..."
mkdir -p /publico /adm /ven /sec

echo "2. Criando grupos de usuários..."
for grupo in GRP_ADM GRP_VEN GRP_SEC; do
    if getent group "$grupo" > /dev/null; then
        echo "   Grupo $grupo já existe, pulando."
    else
        groupadd "$grupo"
    fi
done

echo "3. Criando usuários e adicionando aos grupos..."
criar_usuario() {
    local usuario="$1"
    local grupo="$2"

    if id "$usuario" &> /dev/null; then
        echo "   Usuário $usuario já existe, pulando."
        return
    fi

    # -m cria o diretório home, -s define o shell padrão.
    # openssl passwd -6 gera o hash SHA-512 (mais seguro que o MD5 de -1).
    useradd "$usuario" -m -s /bin/bash -p "$(openssl passwd -6 "$SENHA_INICIAL")" -G "$grupo"

    # Força a troca de senha no primeiro login.
    chage -d 0 "$usuario"
}

# Usuários de Administração
for u in carlos maria joao; do criar_usuario "$u" GRP_ADM; done

# Usuários de Vendas
for u in debora sebastiana roberto; do criar_usuario "$u" GRP_VEN; done

# Usuários de Segurança/Secretaria
for u in josefina amanda rogerio; do criar_usuario "$u" GRP_SEC; done

echo "4. Configurando dono e grupo dos diretórios..."
chown root:GRP_ADM /adm
chown root:GRP_VEN /ven
chown root:GRP_SEC /sec
chown root:root /publico

echo "5. Configurando permissões de acesso..."
# 770 = root e o grupo do departamento têm acesso total; outros usuários não têm acesso.
chmod 770 /adm /ven /sec

# 1777 = todos podem ler e gravar, mas o sticky bit (o "1") impede que um
# usuário apague ou renomeie arquivos de outro. É o mesmo modelo do /tmp.
chmod 1777 /publico

echo "Infraestrutura provisionada com sucesso!"
