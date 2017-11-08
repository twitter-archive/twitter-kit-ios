<?php
/*
 Copyright 2016-present Google Inc. All Rights Reserved.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

/**
 * Arcanist test parser for xcodebuild + llvm-cov output.
 *
 * Provide parseTestResults with stdout of `xcodebuild`.
 * Provide setCoverageFile with stdout of `llvm-cov show`.
 */
final class XcodeTestResultParser extends ArcanistTestResultParser {

  private $xcodeargs;

  public function setXcodeArgs($args) {
    $this->xcodeargs = $args;
    return $this;
  }

  /**
   * Parses stdout of `xcodebuild` as provided via $test_results and returns an
   * array of ArcanistUnitTestResult instances.
   */
  public function parseTestResults($path, $test_results) {
    if (!$test_results) {
      $result = id(new ArcanistUnitTestResult())
        ->setName("Xcode test engine")
        ->setUserData($this->stderr)
        ->setResult(ArcanistUnitTestResult::RESULT_BROKEN);
      return array($result);
    }

    $arccovmap = null;
    if ($this->enableCoverage) {
      $arccovmap = $this->parseCoverageResults();
    }

    $results = array();
    $accumulator = array();
    $suite = null;

    // Break the test result stdout into lines.
    foreach(preg_split("/((\r?\n)|(\r\n?))/", $test_results) as $line) {
      if ($this->startsWith($line, 'Test Suite')) {
        if (preg_match('/Test Suite \'(.+?)\' started/', $line, $matches)) {
          $suite = $matches[1];
        } else {
          $suite = null;
        }
        continue;
      }

      if (strpos($line, ': error:') !== false) {
          print_r($test_results);
        $result = new ArcanistUnitTestResult();
        $result->setName('xcode-unit-engine');
        foreach ($this->xcodeargs as $arg) {
          if (preg_match('/-scheme (.+)/', $arg, $matches)) {
            $result->setName(trim($matches[1], "'\""));
            break;
          }
        }
        $result->setResult(ArcanistUnitTestResult::RESULT_BROKEN);
        $result->setUserData($line);
        $results []= $result;
        continue;
      }
      // Test has started?
      if ($this->endsWith($line, 'started.')) {
        $accumulator = array();
        continue;
      }
      // Within a test, informational line.
      if (!$this->startsWith($line, 'Test Case')) {
        // Treat these lines as information for the test case.
        $accumulator []= $line;
        continue;
      }

      // End of a test.
      if (!preg_match('/\'-\[\S*\s(?:test)*(.+?)\]\' (.+?) \((.+?) seconds\).$/', $line, $matches)) {
        echo "Unable to parse line:\n$line\n";
        continue;
      }

      $userdata = implode("\n", $accumulator);
      $userdata = str_replace($this->projectRoot.'/', '', $userdata);

      $result = new ArcanistUnitTestResult();
      $result->setName($matches[1]);
      if ($suite) {
        $result->setNamespace($suite);
      }
      switch ($matches[2]) {
        case 'passed':
          $result->setResult(ArcanistUnitTestResult::RESULT_PASS);
          break;
        case 'failed':
          $result->setResult(ArcanistUnitTestResult::RESULT_FAIL);
          break;
      }
      $result->setDuration(floatval($matches[3]));
      $result->setUserData($userdata);
      if ($arccovmap) {
        // TODO(featherless): Rather than provide the same coverage to every
        // test object, identify whether we can provide the coverage once
        // somewhere else.
        $result->setCoverage($arccovmap);
      }
      $results []= $result;

      $accumulator = array();
    }
    
    return $results;
  }

  /**
   * Return a map of filename (relative to $this->projectRoot) to <coverage string>
   * https://secure.phabricator.com/book/phabricator/article/arcanist_coverage/
   */
  private function parseCoverageResults() {
    $filemap = array();
    $filename = null;
    $file = array();
    foreach(preg_split("/((\r?\n)|(\r\n?))/", $this->coverageFile) as $line) {
      if (substr($line, 0, 1) === '/') {
        if ($filename && $this->startsWith($filename, $this->projectRoot)) {
          $filemap[$filename] = $file;
        }
        $file = array();
        $filename = $line;
        continue;
      }
      $file []= $line;
    }
    if ($file && $filename) {
      // Commit the hanging file.
      $filemap[$filename] = $file;
    }

    $arccovmap = array();
    foreach ($filemap as $filename => $coverage) {
      $cov = '';
      foreach ($coverage as $line) {
        if (preg_match('/^ +([0-9]+)|/', $line, $matches)
            && count($matches) > 1) {
          if (intval($matches[1]) > 0) {
            $cov .= 'C'; // Covered
          } else {
            $cov .= 'U'; // Uncovered
          }
          continue;
        }
        // Couldn't find a number
        $cov .= 'N'; // Not executable
      }
      $arcname = str_replace($this->projectRoot.'/', '', $filename);
      $arcname = str_replace(':', '', $arcname);
      $arccovmap[$arcname] = $cov;
    }
    return $arccovmap;
  }

  // http://stackoverflow.com/questions/834303/startswith-and-endswith-functions-in-php
  private function startsWith($haystack, $needle) {
    return $needle === "" || strrpos($haystack, $needle, -strlen($haystack)) !== false;
  }

  // http://stackoverflow.com/questions/834303/startswith-and-endswith-functions-in-php
  function endsWith($haystack, $needle) {
    return $needle === "" || (($temp = strlen($haystack) - strlen($needle)) >= 0 && strpos($haystack, $needle, $temp) !== false);
  }
}
