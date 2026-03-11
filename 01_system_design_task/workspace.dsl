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
            tags "C1, Pipe"    

                -> user "Отправка писем" "HTTPS/REST API"{
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
                tags "C2, Web"
            }

            backend = container "Backend API" {
                description "Бизнес-логика пользователей, рецептов, избранного и аутентификации"
                technology "Python, FastAPI"
                tags "C2"

                -> database "Запрос/изменение данных" "SQLAlchemy ORM / PostgreSQL"
                -> email_service "Отправка писем" "HTTPS/REST API"

                email_notification = component "Email Notification Service" {
                    description "Подготавливает и инициирует отправку email-уведомлений"
                    technology "Python"
                    tags "C3"

                    -> email_service "Отправка письма" "HTTPS/REST API"
                }

                recipe_repo = component "Recipe Repository" {
                    description "Обеспечивает доступ к данным рецептов и ингредиентов"
                    technology "Python, SQLAlchemy ORM"
                    tags "C3"

                    -> database "Запрос/изменение данных" "SQLAlchemy ORM / PostgreSQL" {
                        tags "C3"
                    }
                }

                user_repo = component "User Repository" {
                    description "Обеспечивает доступ к данным пользователей"
                    technology "Python, SQLAlchemy ORM"
                    tags "C3"

                    -> database "Запрос/изменение данных" "SQLAlchemy ORM / PostgreSQL" {
                        tags "C3"
                    }
                }

                auth_service = component "Authentication Service" {
                    description "Аутентификация, регистрация и сценарии сброса пароля"
                    technology "Python"
                    tags "C3"

                    -> user_repo "Чтение и создание учётных записей" "Python"  {
                        tags "C3"
                    }
                    -> email_notification "Запрос отправки писем" "Python" {
                        tags "C3"
                    }
                }

                user_service = component "User Service" {
                    description "Поиск пользователей, изменение данных профиля и управление избранным"
                    technology "Python"
                    tags "C3"
                    -> user_repo "Запрос/изменение данных о пользователе" "Python" {
                        tags "C3"
                    }
                }

                recipe_service = component "Recipe Service" {
                    description "Поиск рецептов, создание и изменение рецептов, ингредиентов"
                    technology "Python"
                    tags "C3"

                    -> recipe_repo "Запрос/изменение данных о рецептах" "Python" {
                        tags "C3"
                    }
                }

                auth_controller = component "Authentication Controller" {
                    description "Обрабатывает запросы на регистрацию, вход и сброс пароля"
                    technology "Python, FastAPI Router, Pydantic"
                    tags "C3, Controller"

                    -> auth_service "Аутентификация пользователя" "Python" {
                        tags "C3"
                    }
                }

                recipe_controller = component "Recipe Controller" {
                    description "Обрабатывает запросы на получение и изменение данных о рецептах"
                    technology "Python, FastAPI Router, Pydantic"
                    tags "C3, Controller"

                    -> recipe_service "Получение/изменение данных о рецептах" "Python" {
                        tags "C3"
                    }
                }

                user_controller = component "User Controller" {
                    description "Обрабатывает запросы на получение и изменение данных о пользователях"
                    technology "Python, FastAPI Router, Pydantic"
                    tags "C3, Controller"

                    -> user_service "Получение/изменение данных о пользователе" "Python" {
                        tags "C3"
                    }
                }

                web_app -> auth_controller "Аутентификация/регистрация" "HTTPS/REST, JSON"
                web_app -> recipe_controller "Получение/изменение данных о рецептах" "HTTPS/REST, JSON"
                web_app -> user_controller "Получение/изменение данных о пользователе" "HTTPS/REST, JSON"

            }

            web_app -> backend "Вызывает API" "HTTPS/REST, JSON" {
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
            // element <tag> {
            //     shape <Box|RoundedBox|Circle|Ellipse|Hexagon|Diamond|Cylinder|Bucket|Pipe|Person|Robot|Folder|WebBrowser|Window|Terminal|Shell|MobileDevicePortrait|MobileDeviceLandscape|Component>
            //     icon <file|url>
            //     width <integer>
            //     height <integer>
            //     background <#rrggbb|color name>
            //     color <#rrggbb|color name>
            //     colour <#rrggbb|color name>
            //     stroke <#rrggbb|color name>
            //     strokeWidth <integer: 1-10>
            //     fontSize <integer>
            //     border <solid|dashed|dotted>
            //     opacity <integer: 0-100>
            //     metadata <true|false>
            //     description <true|false>
            //     properties {
            //         name value
            //     }
            // }
            element "db" {
                shape Cylinder
                icon "src\postgresql.svg"
            }
            element "Web" {
                shape WebBrowser
            }
            element "Pipe" {
                shape Pipe
            }
            element "Controller" {
                shape Component
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
            // exclude "relationship.tag==C1"
            exclude "relationship.tag==C3"
            autoLayout 
        }
        
        component recipe_system.backend {
            include *
            autoLayout
        }

        dynamic recipe_system.backend "01" "Сценарий регистрации пользователя" {
            guest -> recipe_system.web_app "Отправка формы регистрации"
            recipe_system.web_app -> recipe_system.backend.auth_controller "POST /auth/register с данными пользователя"
            recipe_system.backend.auth_controller -> recipe_system.backend.auth_service "Передача запроса на регистрацию"
            recipe_system.backend.auth_service -> recipe_system.backend.user_repo "Проверка уникальности login/email"
            recipe_system.backend.user_repo -> recipe_system.database "Чтение данных пользователя"
            recipe_system.backend.auth_service -> recipe_system.backend.user_repo "Создаёт новую учётную запись"
            recipe_system.backend.user_repo -> recipe_system.database "Сохраняет нового пользователя"
            recipe_system.backend.auth_service -> recipe_system.backend.email_notification "Запрашивает отправку письма подтверждения"
            recipe_system.backend.email_notification -> email_service "Отправляет письмо подтверждения"
            email_service -> user "Доставляет письмо подтверждения регистрации"
            recipe_system.backend.auth_controller -> recipe_system.web_app "Возвращает результат успешной регистрации"
            
            autoLayout
        }
    }
}