class PasswordTooShort(Exception):
    pass

class PasswordTooLong(Exception):
    pass

class InvalidPassword(Exception):
    pass


def validate_password():
    input_pass = input("Ivesk slaptazodi: ")
    if len(input_pass) < 3:
        raise PasswordTooShort("trumpas")
    elif len(input_pass) > 30:
        raise PasswordTooLong("trumpas")
    
