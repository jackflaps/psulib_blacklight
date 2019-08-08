/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

require.context('../psulib_blacklight/images/', true)

import Rails from 'rails-ujs';
import Turbolinks from 'turbolinks';
document.addEventListener("DOMContentLoaded", function(event) {
    Rails.start();
    Turbolinks.start();
});

import 'psulib_blacklight'
import 'psulib_blacklight_range_limit'
import 'blacklight_overrides'
import {executeAskALibrarian} from 'ask_a_librarian';

document.addEventListener("turbolinks:load", function() {
    executeAskALibrarian()
});
