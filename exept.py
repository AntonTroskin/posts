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
print(random.choice(rand_exc))
print(random.random())
print(random)

def random_exception():
    print('kazkas')



random_exception()