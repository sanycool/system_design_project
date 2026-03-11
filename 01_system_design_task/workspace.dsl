workspace {
    name "Система управления рецептами"
    description "Веб-сервис для создания, хранения и публикации рецептов"

    # включаем режим с иерархической системой идентификаторов
    !identifiers hierarchical

    model {
        properties { 
            structurizr.groupSeparator "/"
            workspace_cmdb "cmdb_mnemonic"
            architect "Щепкин А.И."
        }

        guest = person "Гость" {
            tags "Person, C1"
        }

        user = person "Авторизованный пользователь" {
            tags "Person, C1"
        }
        
        email_service = softwareSystem "E-mail Service" {
            description "Внешний сервис отправки писем для подтверждения регистрации и сброса пароля"
            tags "C1"    

                -> user "Отправка писем" "HTTPS/REST API"{
                    tags "C1"
                }
                -> guest "Отправка писем" "HTTPS/REST API"{
                    tags "C1"
                } 
                
        }

        recipe_system = softwareSystem "Recipe Management System" {
            description "Система для поиска, создания и хранения рецептов"
            tags "C1"

            -> email_service "Отправка писем" "HTTPS/REST API" {
                tags "C1"
            }

            database = container "Database" {
                description "База данных пользователей, рецептов, ингредиентов и избранного"
                technology "PostgreSQL 17"
                tags "C2, db"
            }

            web_app = container "Web Application" {
                description "Веб-приложение для взаимодействия пользователей с системой"
                technology "React"
                tags "C2"
            }

            backend = container "Backend API" {
                technology "FastAPI"
                tags "C2"

                -> database "Запрос/изменение данных" "JDBC/SQL"
                -> email_service "Отправка письем" "HTTPS/REST API"

                email_notification = component "Email Notification Service" {
                    technology "Python"
                    tags "C3"

                    -> email_service "Отправка письма" "HTTPS/REST API"
                }

                recipe_repo = component "Recipe Repository" {
                    technology "Python, SQLAlchemy"
                    tags "C3"

                    -> database "Запрос/изменение данных" "Python, SQLAlchemy"
                }

                user_repo = component "User Repository" {
                    technology "Python, SQLAlchemy"
                    tags "C3"

                    -> database "Запрос/изменение данных" "Python, SQLAlchemy"
                }

                auth_service = component "Authentication Service" {
                    technology "Python"
                    tags "C3"

                    -> user_repo "Запрос данных о пользователе" "SQL TCP:5432"
                    -> email_notification "Отправка письма при регистрации" "REST HTTPS:443"
                }

                user_service = component "User Service" {
                    technology "Python"
                    tags "C3"
                    -> user_repo "Запрос/изменение данных о пользователе" "SQL TCP:5432"
                }

                recipe_service = component "Recipe Service" {
                    technology "Python"
                    tags "C3"

                    -> recipe_repo "Запрос/изменение данных о рецептах" "SQL TCP:5432"
                }

                auth_conroller = component "Authentication Controller" {
                    technology "Python, FastAPI Router, Pydantic"
                    tags "C3"

                    -> auth_service "Аутентификация пользователя" "REST HTTPS:443"
                }

                recipe_controller = component "Recipe Controller" {
                    technology "Python, FastAPI Router, Pydantic"
                    tags "C3"

                    -> recipe_service "Получение/изменение данных о рецептах" "REST HTTPS:443"
                }

                user_controller = component "User Controller" {
                    technology "Python, FastAPI Router, Pydantic"
                    tags "C3"

                    -> user_service "Получение/изменение данных о пользователе" "REST HTTPS:443"
                }

                web_app -> auth_conroller "Аутентификация" "REST HTTPS:443"
                web_app -> recipe_controller "Получение/изменение данных о рецептах" "REST HTTPS:443"
                web_app -> user_controller "Получение/изменение данных о пользователе"

            }

            web_app -> backend "Вызывает API" "HTTPS/REST" {
                tags "C2"
            }
            guest -> web_app "Регистрация, поиск и просмотр рецептов" "HTTPS/REST API" {
                tags "C2"
            }
            user -> web_app "Аутентификация, создание/поиск рецептов" "HTTPS/REST API" {
                tags "C2"
            }
        }

        user -> recipe_system "Получение услуг" {
            tags "C1"
        }
        guest -> recipe_system "Получение услуг" {
            tags "C1"
        }
    }

    views {
        # Конфигурируем настройки отображения plant uml
        properties {
            plantuml.format     "svg"
            kroki.format        "svg"
            structurizr.sort created
            structurizr.tooltips true
        }

        # Задаем стили для отображения
        themes default

        styles {
            // element "Software System" {
            //     background "#1168bd"
            //     color "#ffffff"
            // }
            // element "Person" {
            //     background "#01070E"
            //     color "#ffffff"
            //     shape person
            // }
            element "db" {
                shape Cylinder
            }
        }

        # Диаграмма контекста
        systemContext recipe_system {
            include *
            exclude "relationship.tag==C2"
            autoLayout
        }

        container recipe_system {
            include *
            autoLayout 
        }
        
        component recipe_system.backend {
            include *
            autoLayout
    }
}