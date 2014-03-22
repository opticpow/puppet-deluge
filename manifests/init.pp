# Class to install and configure deluge daemon
class deluge {

    package {
        'deluged':
            ensure => present;

        'deluge-web':
            ensure => present;
    }

    group {
        'deluge':
            ensure => present,
            system => true;
    }

    user {
        'deluge':
            ensure     => present,
            home       => '/var/lib/deluge',
            managehome => true,
            system     => true,
            gid        => 'deluge',
            require    => Group['deluge'];
    }


    file {
        '/etc/init/deluged.conf':
            ensure  => file,
            mode    => '0644',
            owner   => root,
            group   => root,
            source  => 'puppet:///modules/deluge/deluged.conf',
            require => [Package['deluged'], User['deluge']];

        '/etc/init/deluge-web.conf':
            ensure  => file,
            mode    => '0644',
            owner   => root,
            group   => root,
            source  => 'puppet:///modules/deluge/deluge-web.conf',
            require => [Package['deluge-web'], User['deluge']];

        '/var/log/deluge':
            ensure => directory,
            mode   => 0750,
            owner  => deluge,
            group  => deluge;

    }

    service {
        'deluged':
            ensure   => running,
            provider => upstart,
            subscribe  => File['/etc/init/deluged.conf'];

        'deluge-web':
            ensure     => running,
            provider => upstart,
            subscribe  => File['/etc/init/deluge-web.conf'];

    }

    logrotate::rule { 'deluge':
        path          => '/var/log/deluge/*.log',
        rotate        => 4,
        rotate_every  => week,
        sharedscripts => true,
        missingok     => true,
        delaycompress => true,
        ifempty       => false,
        compress      => true,
        postrotate    => 'initctl restart deluged ; initctl restart deluge-web';
    }
}

