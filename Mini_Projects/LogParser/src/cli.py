from argparse import ArgumentParser, Namespace

class Cli:
    def Verbose(self, input1,input2):
        # Lists to hold positive and negative log events.
        Positive: list = []
        Negative: list = []
        # Adding formatting + colours that stand out to grabn the users attention.
        for i in input1:
            if "successfully" in i:
                Positive.append(f"\033[1;92mSuccessful event: {i}\033[0m")
            else:
                Negative.append(f"\033[1;91mError event: {i}\033[0m")

        # Loop each line in the lists, printing finalised data.
        for i in Positive:
            print(i)
        for i in Negative:
            print(i)
        print(f"\033[1;50mTotal success count: {input2[1]}\nTotal failure count: {input2[0]}\033[0m")
            
    def NonVerbose(self, input):
        print(f"\n\n\n\033[1;92mSuccessful event count: {input[0]}\033[0m\n\033[1;91mError event count: {input[1]}\033[0m\n\n\n")

    def args(self) -> str:
        # Defining argumnets to be parsed
        parser = ArgumentParser()
        parser.usage = ("Select verbose using python main.py -v 0 or -v1" )
        parser.add_argument("-v", "--verbose", help="Verbose provides a more advanced output description.",type=int ,choices=[0,1])
        
        # Parsing args and returning the verbose count.
        arg: Namespace = parser.parse_args()
        result: int = arg.verbose
        return result
