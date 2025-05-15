
create table article_urls
(
    id            int auto_increment
        primary key,
    url           varchar(512)                                                                    not null,
    title         varchar(255)                                                                    null,
    source        varchar(100)                                                                    null,
    status        enum ('pending', 'processing', 'completed', 'failed') default 'pending'         null,
    created_at    datetime                                              default CURRENT_TIMESTAMP null,
    updated_at    datetime                                              default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    published_at  datetime                                                                        null,
    error_message text                                                                            null,
    retry_count   int                                                   default 0                 null,
    saved_path    varchar(512)                                                                    null,
    constraint url
        unique (url)
);

create index idx_status
    on article_urls (status);

create index idx_url
    on article_urls (url);

create table budget_categories
(
    id                 bigint unsigned auto_increment
        primary key,
    user_id            bigint unsigned null,
    is_family_budget   tinyint(1)      null,
    family_id          bigint unsigned null,
    name               longtext        null,
    description        longtext        null,
    icon_id            bigint unsigned null,
    budget             double          null,
    spent              double          null,
    year               bigint          null,
    month              bigint          null,
    reminder_threshold bigint          null,
    created_at         datetime(3)     null,
    updated_at         datetime(3)     null
);

create table family_invitations
(
    id          int unsigned auto_increment comment '主键ID'
        primary key,
    owner_id    int unsigned                       not null comment '家主用户ID，发起邀请的家庭',
    invite_code varchar(20)                        not null comment '邀请码，用于加入家庭',
    expire_time datetime                           not null comment '邀请码过期时间',
    created_at  datetime default CURRENT_TIMESTAMP not null comment '创建时间',
    updated_at  datetime default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP comment '更新时间',
    constraint uk_invite_code
        unique (invite_code) comment '邀请码唯一索引'
)
    comment '家庭邀请表' collate = utf8mb4_unicode_ci;

create index idx_owner_id
    on family_invitations (owner_id)
    comment '家主ID索引';

create table family_members
(
    id          int unsigned auto_increment comment '主键ID'
        primary key,
    owner_id    int unsigned                           not null comment '家主用户ID，标识该成员属于哪个家庭',
    user_id     int unsigned default '0'               not null comment '用户ID，如果是0表示是虚拟成员',
    name        varchar(50)                            not null comment '成员姓名',
    nickname    varchar(50)                            null comment '家庭称呼，如"爸爸"、"妈妈"等',
    description varchar(255)                           null comment '成员描述',
    phone       varchar(20)                            null comment '联系电话',
    role        varchar(20)                            not null comment '角色，如"家庭主账户"、"配偶"、"子女"、"其他"',
    avatar_url  varchar(255)                           null comment '头像URL',
    join_time   datetime                               not null comment '加入家庭时间',
    permission  varchar(20)                            not null comment '权限级别，如"查看者"、"编辑者"、"管理者"',
    created_at  datetime     default CURRENT_TIMESTAMP not null comment '创建时间',
    updated_at  datetime     default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP comment '更新时间',
    gender      varchar(200) default ''                not null comment 'gender'
)
    comment '家庭成员表' collate = utf8mb4_unicode_ci;

create index idx_owner_id
    on family_members (owner_id)
    comment '家主ID索引，用于快速查询家庭成员';

create index idx_user_id
    on family_members (user_id)
    comment '用户ID索引，用于查询特定用户的家庭关系';

create table feedback
(
    id             bigint unsigned auto_increment
        primary key,
    created_at     datetime(3)     null,
    updated_at     datetime(3)     null,
    user_id        bigint unsigned null,
    title          longtext        null,
    description    longtext        null,
    status         longtext        null,
    screenshot_url longtext        null
);

create table feedback_timeline
(
    id          bigint unsigned auto_increment
        primary key,
    created_at  datetime(3)     null,
    updated_at  datetime(3)     null,
    feedback_id bigint unsigned null,
    status      longtext        null,
    comment     longtext        null,
    operator_id bigint unsigned null,
    operator    longtext        null
);

create table folder
(
    id           bigint unsigned auto_increment
        primary key,
    created_at   datetime(3)                   null,
    updated_at   datetime(3)                   null,
    name         varchar(255)                  not null,
    user_id      bigint unsigned               not null,
    parent_id    bigint unsigned               null,
    is_deleted   tinyint(1)  default 0         null,
    deleted_at   datetime(3)                   null,
    description  varchar(500)                  null,
    access_level varchar(20) default 'private' null
);

create table icon_categories
(
    id          int auto_increment
        primary key,
    name        varchar(50)                         not null,
    code        varchar(50)                         not null,
    description varchar(200)                        null,
    sort_order  int       default 0                 null,
    created_at  timestamp default CURRENT_TIMESTAMP null,
    updated_at  timestamp default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint code
        unique (code)
);

create table icons
(
    id          int auto_increment
        primary key,
    category_id int                                  not null,
    name        varchar(50)                          not null,
    code        varchar(50)                          not null,
    icon_type   varchar(20)                          not null,
    icon_code   varchar(50)                          not null,
    color_code  varchar(20)                          not null,
    is_public   tinyint(1) default 1                 null,
    sort_order  int        default 0                 null,
    created_at  timestamp  default CURRENT_TIMESTAMP null,
    updated_at  timestamp  default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    user_id     int        default 0                 not null comment '用户ID',
    constraint icons_ibfk_1
        foreign key (category_id) references icon_categories (id)
);

create index category_id
    on icons (category_id);

create table plans
(
    id                 bigint unsigned auto_increment
        primary key,
    created_at         datetime(3)  null,
    updated_at         datetime(3)  null,
    deleted_at         datetime(3)  null,
    age                int          not null,
    weight             double       not null,
    height             double       not null,
    sex                varchar(10)  not null,
    activity_level     varchar(50)  not null,
    dietary_preference varchar(100) not null,
    fitness_goals      varchar(100) not null,
    country            varchar(50)  not null,
    language           varchar(10)  not null,
    dietary_plan       text         not null,
    workout_plan       text         not null
)
    collate = utf8mb4_unicode_ci;

create index idx_plans_deleted_at
    on plans (deleted_at);

create table publish_history
(
    id            int auto_increment
        primary key,
    article_id    int                                                  null,
    publish_time  datetime                   default CURRENT_TIMESTAMP null,
    status        enum ('success', 'failed') default 'success'         null,
    error_message text                                                 null,
    constraint publish_history_ibfk_1
        foreign key (article_id) references article_urls (id)
);

create index idx_article
    on publish_history (article_id);

create table resource
(
    id           bigint unsigned auto_increment
        primary key,
    created_at   datetime(3)                    null,
    updated_at   datetime(3)                    null,
    name         varchar(255)                   not null,
    type         varchar(500) default ''        not null,
    mime_type    varchar(100)                   null,
    size         bigint       default 0         null,
    user_id      bigint unsigned                not null,
    folder_id    bigint unsigned                null,
    path         varchar(1000)                  null,
    is_deleted   tinyint(1)   default 0         null,
    deleted_at   datetime(3)                    null,
    downloads    bigint       default 0         null,
    description  varchar(500)                   null,
    access_level varchar(20)  default 'private' null,
    oss_url      varchar(1000)                  null
);

create table savings_goals
(
    id             bigint unsigned auto_increment
        primary key,
    user_id        bigint unsigned                    null,
    is_family_goal tinyint(1)                         null,
    family_id      bigint unsigned                    null,
    name           longtext                           null,
    icon_id        bigint unsigned                    null,
    target_amount  double                             null,
    current_amount double                             null,
    description    longtext                           null,
    monthly_target double                             null,
    target_date    datetime(3)                        null,
    note           longtext                           null,
    created_at     datetime(3)                        null,
    updated_at     datetime(3)                        null,
    status         varchar(191) default 'in_progress' null,
    completed_at   datetime(3)                        null
);

create table transactions
(
    id                bigint unsigned auto_increment
        primary key,
    user_id           bigint unsigned      null comment '用户ID',
    type              varchar(10)          not null comment '交易类型(expense/income)',
    amount            double               not null comment '金额',
    icon_id           bigint               null comment '关联的图标ID',
    date              datetime(3)          not null comment '交易日期',
    merchant          varchar(100)         null comment '商家名称',
    notes             text                 null comment '备注',
    recorder_id       bigint unsigned      null comment '记账人(家庭成员)ID',
    is_family_expense tinyint(1) default 0 null comment '是否记为家庭支出',
    image_url         varchar(255)         null comment '关联图片URL',
    created_at        datetime(3)          null,
    updated_at        datetime(3)          null,
    category_id       bigint               null comment '交易分类ID'
);

create index idx_transactions_category_id
    on transactions (category_id);

create index idx_transactions_date
    on transactions (date);

create index idx_transactions_recorder_id
    on transactions (recorder_id);

create index idx_transactions_type
    on transactions (type);

create index idx_transactions_user_id
    on transactions (user_id);

create table user
(
    id         int unsigned auto_increment
        primary key,
    phone      varchar(20)      not null,
    nickname   varchar(50)      null,
    avatar     varchar(255)     null,
    status     bigint default 1 null,
    last_login datetime(3)      null,
    created_at datetime(3)      null,
    updated_at datetime(3)      null,
    deleted_at datetime(3)      null,
    constraint idx_phone
        unique (phone),
    constraint idx_user_phone
        unique (phone)
)
    collate = utf8mb4_unicode_ci;

create index idx_deleted_at
    on user (deleted_at);

create index idx_user_deleted_at
    on user (deleted_at);

create table user_icons
(
    category_id  int                                 not null,
    id           int auto_increment
        primary key,
    user_id      int                                 not null,
    icon_id      int                                 not null,
    custom_name  varchar(50)                         null,
    custom_color varchar(20)                         null,
    created_at   timestamp default CURRENT_TIMESTAMP null,
    updated_at   timestamp default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint user_icons_ibfk_1
        foreign key (icon_id) references icons (id)
);

create index icon_id
    on user_icons (icon_id);

create table user_profile
(
    id            int unsigned auto_increment comment '主键ID'
        primary key,
    user_id       bigint unsigned not null comment '''关联的用户ID''',
    gender        varchar(10)     null comment '''性别：male-男性, female-女性, other-其他''',
    birthday      datetime(3)     null comment '''生日，格式为YYYY-MM-DD''',
    height        double          null comment '''身高(cm)''',
    weight        double          null comment '''体重(kg)''',
    blood_type    varchar(10)     null comment '''血型，如A、B、AB、O、A+、A-等''',
    occupation    varchar(50)     null comment '''职业''',
    address       varchar(255)    null comment '''居住地址''',
    emerg_contact varchar(50)     null comment '''紧急联系人姓名''',
    emerg_phone   varchar(20)     null comment '''紧急联系人电话''',
    bio           varchar(500)    null comment '''个人简介''',
    created_at    datetime(3)     null comment '''创建时间''',
    updated_at    datetime(3)     null comment '''更新时间''',
    deleted_at    datetime(3)     null comment '''删除时间（软删除）''',
    constraint user_id
        unique (user_id)
)
    comment '用户个人基本信息表' collate = utf8mb4_unicode_ci;

create table users
(
    id            bigint unsigned auto_increment
        primary key,
    username      varchar(32)      not null,
    password      varchar(128)     not null,
    email         varchar(128)     not null,
    avatar        varchar(255)     null,
    created_at    datetime(3)      null,
    updated_at    datetime(3)      null,
    deleted_at    datetime(3)      null,
    phone         varchar(20)      not null,
    nickname      varchar(50)      null,
    status        bigint default 1 null,
    last_login_at datetime(3)      null,
    registered_at datetime(3)      null,
    last_login    datetime(3)      null,
    constraint idx_users_phone
        unique (phone),
    constraint uk_email
        unique (email),
    constraint uk_username
        unique (username)
)
    collate = utf8mb4_unicode_ci;

create index idx_users_deleted_at
    on users (deleted_at);

create table videos
(
    id                 bigint unsigned auto_increment comment '主键ID'
        primary key,
    created_at         datetime(3)                      null comment '创建时间',
    updated_at         datetime(3)                      null comment '更新时间',
    deleted_at         datetime(3)                      null comment '删除时间',
    user_id            bigint unsigned                  not null comment '用户ID',
    name               varchar(255)                     not null comment '视频名称',
    original_filename  varchar(255)                     null comment '原始文件名',
    file_path          varchar(255)                     not null comment '文件路径',
    oss_object_key     varchar(255)                     null comment 'OSS对象键',
    file_size          bigint                           null comment '文件大小(字节)',
    duration           int                              null comment '视频时长(秒)',
    thumbnail_path     varchar(255)                     null comment '缩略图路径',
    output_path        varchar(255)                     null comment '输出文件路径',
    status             varchar(20) default 'processing' null comment '处理状态',
    error_message      varchar(500)                     null comment '错误信息',
    commentary_style   varchar(50)                      null comment '解说风格',
    voice_gender       varchar(20)                      null comment '语音性别',
    commentary_lang    varchar(10)                      null comment '解说语言',
    speech_rate        double      default 1            null comment '语速',
    bg_music           varchar(50)                      null comment '背景音乐',
    subtitle           varchar(20)                      null comment '字幕类型',
    process_start_time datetime                         null comment '处理开始时间',
    process_end_time   datetime                         null comment '处理结束时间'
)
    comment '视频表' collate = utf8mb4_unicode_ci;

create index idx_videos_deleted_at
    on videos (deleted_at);

create index idx_videos_user_id
    on videos (user_id);

