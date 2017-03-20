define spacewalk_client::gpg_key (
    $key_name,
    $key_source,
    ) {

    # add gpg key
    exec { "add_gpg_key_${key_name}":
        command     => "rpm --import ${key_source}"
    }
}