# Описание скриптов

## docker-network-by-default.sh

Скрипт, выставляющий дефолтный пул адресов и подсетей для вновь созданных контейнеров

Начиная с версии 18.09.1, появилась возможность использовать выдачу подсетей по дефолту для вновь созданных контейнеров.

Выглядит это вот  так:
```
 "default-address-pools" : [
    {
      "base" : "172.200.0.0/16",
      "size" : 24
    }
  ]
```
Т.е. для каждого нового композа, при условии что сеть в нём не указана (дефолтная), сеть будет создаваться вида 172.200.*.0/24.
Запущенные же контейнеры командой docker run будут попадать в нулевую сеть 172.200.0.0/24.
Новая версия скрипта с этим изменением залита
сюда
(git clone https://bitbucket.ap-team.ru/scm/ops/eberil.git)
После запуска скрипт:
1. проверяет наличие файла конфигурации докера, создаёт если отсутствует. Если файл уже есть, делает копию в /etc/docker/;
2. применяет настройки докера путём перезапуска сокета;
3. тестирует, получил ли контейнер редиса, запущенный через docker-compose правильный адрес. (edited)

## Инструкция по применению: 
1. склонировать репозиторий;
2. сделать sudo chmod +x {имя.скрипта};
3. запустить скрипт.