import random

#
# # raise Exception("naujas erroras")
#
# try:
#     my_l = ["pirmas"]
#     print("exceptaas veikia")
#     print(my_l[1])
# except:
#     print("kitkas")

rand_exc = [IndexError, SyntaxError, KeyboardInterrupt]
# print(random.choice(rand_exc))
# print(random.random())
# print(random)
exc_type = {}

error_count = {}
def random_exception():
    raise random.choice(rand_exc)

for exc_type in rand_exc:
    error_count[exc_type] = 0

print(error_count)

for _ in range(10):
    try:
        random_exception()
    except IndexError:
        error_count[IndexError] += 1
        print("pagautas indexerroras")
    except SyntaxError:
        error_count[SyntaxError] += 1
        print("pagautas syntakses eroras")
    except KeyboardInterrupt:
        error_count[KeyboardInterrupt] += 1
        print("pagautas keybordo eroras")


# x = {exc_type: 0 for exc_type in rand_exc}
# print(x)



print(error_count)