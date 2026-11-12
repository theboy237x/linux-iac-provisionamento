# 🐧 Infraestrutura como Código (IaC): provisionamento de usuários e permissões no Linux

Script Bash que cria e configura automaticamente o ambiente de trabalho de uma empresa fictícia em um servidor Linux: pastas por departamento, grupos, usuários e permissões.

## 🎯 Objetivo

Em empresas, criar usuários, grupos e pastas à mão consome tempo do time de suporte e abre espaço para erro humano, como um acesso liberado para a pessoa errada. Este script automatiza o processo e aplica dois conceitos de segurança da informação:

- **RBAC (Role-Based Access Control):** o acesso é dado pelo departamento (grupo), não usuário por usuário.
- **Princípio do menor privilégio:** cada pessoa acessa só a pasta do próprio setor.

## ⚙️ O que o script faz

| Etapa | O que acontece |
|---|---|
| Diretórios | Cria `/publico`, `/adm`, `/ven` e `/sec` |
| Grupos | Cria `GRP_ADM`, `GRP_VEN` e `GRP_SEC` |
| Usuários | Cria 9 usuários (3 por departamento), com shell Bash, senha inicial em hash SHA-512 e **troca de senha obrigatória no primeiro login** |
| Donos | `root` é dono das pastas; cada pasta pertence ao grupo do seu departamento |
| Permissões | `770` nas pastas dos departamentos (só o grupo acessa) e `1777` em `/publico` |

### Por que `1777` e não `777` no `/publico`?

Com `777`, qualquer usuário pode **apagar arquivos dos outros**. O `1` na frente liga o *sticky bit*: todos continuam podendo ler e gravar, mas cada um só apaga o que é seu. É o mesmo modelo usado no `/tmp` do Linux.

## 🛡️ Cuidados de segurança

- O script só roda como root e para no primeiro erro (`set -euo pipefail`).
- Pode ser executado mais de uma vez: grupos e usuários que já existem são ignorados.
- A senha inicial é só para **laboratório**. Em produção, ela viria de um cofre de senhas ou seria gerada aleatoriamente.

## 🚀 Como executar

Use uma máquina virtual de testes, nunca um servidor de produção.

```bash
git clone https://github.com/theboy237x/linux-iac-provisionamento.git
cd linux-iac-provisionamento
chmod +x iac_setup.sh
sudo ./iac_setup.sh
```

## ✅ Como verificar

```bash
ls -ld /publico /adm /ven /sec    # donos e permissões
getent group GRP_ADM GRP_VEN GRP_SEC
sudo chage -l carlos              # deve pedir troca de senha
su - debora -c "ls /adm"          # deve falhar: debora é de Vendas
```

## 📚 O que pratiquei

Administração de usuários e grupos no Linux, permissões (`chmod`, `chown`, sticky bit), políticas de senha (`chage`), automação com Bash e boas práticas de controle de acesso.
