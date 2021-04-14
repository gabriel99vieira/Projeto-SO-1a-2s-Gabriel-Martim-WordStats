
# Word Stats

Project carried out under the Operating Systems discipline of the Computer Engineering course at the Polytechnic Institute of Leiria - ESTG

## Getting Started

These instructions will get you a copy of the project up and running on your local machine.
See deployment for notes on how to start the project on your system.

### Prerequisites

First of all make shure you have these if you are planning o using the PDF extension

```
sudo apt install poppler-utils
sudo apt install gnuplot
```

## How to use

The script works on 3 main modes, having all of them 2 types of execution as listed bellow:

* **Count Mode** 
	* Counts all occurences of words in the given file omitting stopwords and output the results to another file.
		* *c* - With stopwords
			* `./wordStats.sh c samples/sample.en.txt en`
		* *C* - Without stopwords
			* `./wordStats.sh C samples/sample.en.txt en`

* **Top Mode**
	* Same as count mode but displays only the top selected. (Environment variable `WORD_STATS_TOP`)
		* Quick recap on environment variables
			* View - `printenv`, `env` or `export`
			* Set - `export WORD_STATS_TOP=5`
			* Unset - `unset WORD_STATS_TOP`
		* *t* - With stopwords
			* `./wordStats.sh t samples/sample.en.txt en`
		*  *T* - Without stopwords
			* `./wordStats.sh T samples/sample.en.txt en`
* **Plot Mode** 
	* Same as top mode but the results are exported in a plot and shown after running the script (Also available  through a simple HTML page).
		* *p* - With stopwords
			* `./wordStats.sh p samples/sample.en.txt en`
		*  *P* - Without stopwords
			* `./wordStats.sh P samples/sample.en.txt en`


### Results

Results can accessed in the `/results/` directory. 
These will have a distinct output based on the input file.
If the input file is the same or has the same name then the output will be overwritten.
The output follows the following pattern:

* All modes
	* `result---{input_file_with_extension}.txt`
	
* **p** mode
	* `result---{input_file_with_extension}.html`
	* `result---{input_file_with_extension}.png`

## Extending

Stopwords can be added/modified to a specific language.
To manage the stopwords, files are present in the `/StopWords/` directory. These must follow a specific pattern to ensure the correct execution of the script.

As example: `{lang}.stop_words.txt` where `{lang}` can be `en`, `pt`...
In this file you can reference a stopword for **each line**.
```
stop_word_1
stop_word_2
stop_word_3
...
```

## Built With

* [gnuplot homepage (sourceforge.net)](http://gnuplot.sourceforge.net/) - Plot builder

## Visual Studio Code Extensions

 * BASH Extension Pack: https://marketplace.visualstudio.com/items?itemName=lizebang.bash-extension-pack

 * Better Comments: https://marketplace.visualstudio.com/items?itemName=aaron-bond.better-comments

 * Comment V: https://marketplace.visualstudio.com/items?itemName=karyfoundation.comment

## Authors

* **Gabriel Madeira Vieira** - *Developer and documentation writter* - nº 2200661
* **Martim Teixeira da Silva** - *Developer and documentation writter* - nº 2200681

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
