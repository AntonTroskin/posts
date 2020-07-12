import random

klaidu_sarasas = [IndexError, SyntaxError, KeyboardInterrupt]
error_caunt = {}

for klaidos_tipas in klaidu_sarasas:
    error_caunt[klaidos_tipas] = 0
print(error_caunt)


def random_exception(sarasas):
    raise random.choice(sarasas)


for i in range(5):
    try:
        random_exception(klaidu_sarasas)
    except IndexError:
        print("pagautas IndexError'as")
        error_caunt[IndexError] += 1
    except SyntaxError:
        print("pagautas SyntaxError")
        error_caunt[SyntaxError] += 1
    except KeyboardInterrupt:
        print("pagautas KeyboardInerrupt")
        error_caunt[KeyboardInterrupt] += 1

print("rezultatas - ", error_caunt)

# x = {klaidos_tipas : 0 for klaidos_tipas in klaidu_sarasas}


# print(x)

# random_exception(klaidu_sarasas)


# naujas_dic = error_caunt[IndexError]
# print(naujas_dic)
# error_caunt[IndexError] = 0
# error_caunt[IndexError] += 1
# print(error_caunt[IndexError])


# print(x)