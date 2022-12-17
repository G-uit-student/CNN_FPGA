import matplotlib.pyplot as plt

if __name__ == '__main__':
    results = open("./sigmoid.log", "r")

    x = []
    error = []

    for line in results:
        if "x" in line:
            x.append(float(line.replace("x: ", "")))
        if "error" in line:
            error.append(float(line.replace("error: ", "")))

    plt.plot(x, error)
    plt.ylim([0, 0.02])
  
    plt.xlabel('x')
    plt.ylabel('error')
    
    plt.title('sigmoid error')

    plt.show()
