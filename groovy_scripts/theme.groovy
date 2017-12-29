#!groovy

import hudson.model.PageDecorator;

for (pd in PageDecorator.all()) {
  if (pd instanceof org.codefirst.SimpleThemeDecorator) {
    pd.cssUrl = 'https://cdn.rawgit.com/afonsof/jenkins-material-theme/gh-pages/dist/material-blue-grey.css'
  }
}
