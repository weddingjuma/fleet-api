SimpleCov.start do
    add_filter '/lib/'
    add_filter '/vendor/'
    add_filter '/config/'
    add_filter '/spec/'
    add_filter '/test/'

    add_group 'Controllers',    'app/controllers'
    add_group 'Models',         'app/models'
    add_group 'Policies',       'app/policies'
    add_group 'Serializers',    'app/serializers'
end if ENV["COVERAGE"]
