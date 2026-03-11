workspace {
    name "имя продукта"
    description "описание продукта"

    # включаем режим с иерархической системой идентификаторов
    !identifiers hierarchical

    model {
        properties { 
            structurizr.groupSeparator "/"
            workspace_cmdb "cmdb_mnemonic"
            architect "имя архитектора"
        }

        my_user    = person "B2C пользователь"
        my_admin   = person "Администратор системы"
        my_support = person "Специалист ТП"

        my_system = softwareSystem "system name"{
            topic1 = container "Topic name"{
                technology "Kafka"
                tags "kafka"
            }

            scheme1 = container "Scheme name"{
                technology "PostgreSQL 14"
                tags "postgre"
            }

            mongo1 = container "Mongo server"{
                technology "MongoDB"
                tags "mongo"
            }

            s3_storage = container "S3 Storage" {
                technology "ceph"
                tags "s3"
            }

            cache1 = container "Cache server" {
                technology "Redis"
                tags "redis"
            }

            srv1 = container "Service 1" {
                technology "Spring"
                tags "java"
                -> topic1 "Публикация событий" "KAFKA TCP:9092"
                -> scheme1 "Запрос/изменение данных" "SQL TCP:5432"
            }

            srv2 = container "Service 2" {
                technology "Golang"
                tags "go"
                -> s3_storage "Запрос/сохранение файлов" "S3 HTTPS:443"
                -> mongo1 "Запрос/сохранение документов"
            }

            gw = container "API Gateway" {
                technology "Spring Cloud Gateway"
                tags "java"
                -> srv1 "Описание запроса" "REST HTTPS:443"
                -> srv2 "Описание запроса" "REST HTTPS:443"
                -> cache1 "Запрс кеша сессий" "REST HTTPS:443"
            }

            bff = container "BFF Web" {
                technology "Spring"
                tags "java"
                -> gw "Описание запроса" "REST HTTPS:443"
            }

            fe = container "Frontend" {
                technology "React"
                tags "js"
                -> bff "Описание запроса" "REST HTTPS:443"
            }
        }

        deploymentEnvironment "PROD" {
                # если необходима DMZ
                deploymentNode "Demilitarized Zone" {
                    deploymentNode "kubernates.namespace.dmz" {
                        deploymentNode "pod_name_1" {
                            containerInstance my_system.fe
                            instances 2
                        }
                    }
                }
                deploymentNode "Protected Zone" {
                    deploymentNode "kubernates.namespace.protected" {
                        deploymentNode "pod_name_2" {
                            containerInstance my_system.bff
                            instances 2
                        }
                        deploymentNode "pod_name_3" {
                            containerInstance my_system.gw
                            instances 2
                        }
                        deploymentNode "pod_name_4" {
                            containerInstance my_system.srv1
                        }
                        deploymentNode "pod_name_5" {
                            containerInstance my_system.srv2
                        }
                        deploymentNode "pod_name_6" {
                            containerInstance my_system.topic1
                        }
                        deploymentNode "pod_name_7" {
                            containerInstance my_system.scheme1
                        }
                        deploymentNode "pod_name_8" {
                            containerInstance my_system.mongo1
                        }
                        deploymentNode "pod_name_9" {
                            containerInstance my_system.s3_storage
                        }
                        deploymentNode "pod_name_10" {
                            containerInstance my_system.cache1
                        }
                       }
                    }
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


        # Диаграмма контекста
        systemContext my_system {
            include *
            autoLayout
        }

        container my_system {
            include *
            autoLayout 
        }

        deployment * "PROD" {
            include *
            autoLayout 
        }

    }
}