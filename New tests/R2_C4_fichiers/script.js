
(function ($) {
    $(document).ready(function() {

        var timer_start = (new Date).getTime();

        //                elm.css({'-moz-border-radius' : '7px', '-webkit-border-radius': '7px', 'border-radius' : '7px'});
        //                elm.find('.hightlight-left').css({'-moz-border-radius' : '7px, 0, 0, 7px', '-webkit-border-radius': '7px, 0, 0, 7px', 'border-radius' : '7px, 0, 0, 7px'});
        //                elm.find('.hightlight-img img').css({'-moz-border-radius' : '0, 7px, 7px, 0', '-webkit-border-radius': '0, 7px, 7px, 0', 'border-radius' : '0, 7px, 7px, 0'});

        //        if ($.browser.msie == true) {
        //            if(parseInt($.browser.version) != 7) {
        //                $(document.body).addClass('no-ie7');
        //            }
        //        }
        //        else {
        //            $('body').addClass('no-ie7');
        //        }
        // && parseInt($.browser.version) != 7

        // Image for help menu in region-right
        auto_va(
        '#block-views-pmu-help-menu-block .views-field-scald-thumbnail .field-content',
        '#block-views-pmu-help-menu-block .views-field-scald-thumbnail .field-content img');

        /**
         *v1.0-beta1
         * Auto vertical align absolute methode
         *
         * param parent    : parent element
         * param children   : children element (have to vertical align middle)
         * param pos_left : left position of children element (insite parent element) (can be null)
         * param padd_left : left padding of parent element (can be null)
         * param margin_top_correction : top margin of children element (can be null)
         */
        function auto_va(parent, children, pos_left, padd_left, margin_top_correction) {
            $(parent).each(function(i,v) {
                if($(v).length) {
                    if(padd_left == null) {
                        padd_left = 0;
                    }
                    if(margin_top_correction == null) {
                        margin_top_correction = 0;
                    }

                    var parent_height  = $(v).height();
                    var children_width  = $(v).children(children).width();
                    var children_height = $(v).children(children).height();

                    $(v).css('position', 'relative');
                    //$(v).css('padding-left', children_width + padd_left + 'px');

                    $(v).children(children).css('display', 'block');
                    $(v).children(children).css('position', 'absolute');
                    $(v).children(children).css('top', '50%');
                    $(v).children(children).css('margin-top', - children_height / 2 + margin_top_correction);
                    //if(pos_left != null) $(v).children(children).css('left', pos_left + 'px');

                }
            });
        }

        // ENTREPRISE - VIEWS EXPOSED
        my_custom_form('select', 'form#views-exposed-form-pmu-press-communique-page', 'edit-field-date-value-value-year', 'edit-field-date-value-value-year-fake', null, null, null)
        my_custom_form('select', 'form#views-exposed-form-pmu-press-communique-page', 'edit-field-date-value-value-month', 'edit-field-date-value-value-month-fake', null, null, null)
        my_custom_form('select', 'form#views-exposed-form-pmu-press-communique-page', 'edit-field-ref-taxo-theme-tid', 'edit-field-ref-taxo-theme-tid-fake', null, null, null)

        /* v1.1
         * Add a specific background on different form element, like a select, a input file or a date calendar
         * This using a mixin .my-custom-form() whitch define default css class for all our element.
         *
         * Param type : type of element to manipulate : 'select', 'input_file' or 'date_calendar'
         * Param zone : the zone where is our element. To be sure we are in good form. Used for ajax event too.
         * Param element_id : our element'id that we need to manipulate
         * Param fake_id : our fake element's id we want to insert by prepend method (before element_id) (have to be unique)
         * Param element_addclass : add a specific class on our element form (can be null)
         * Param wrapper_addclass : add a specific class on our wrapper. Wrapper is token by parent element_id (can be null)
         * Param ajax_event : attach a even to this form, if the form is relaoaded for exemple (and so recall the function) (can be null)
         */

        function my_custom_form(type, zone_path, element_id, fake_id, element_addclass, wrapper_addclass, ajax_event) {

            /**
             *
             * Check if we have an ajax event
             * Check if our form element exist
             * Check if we have our fake element. If fake element isnt here, we call the function
             *
             */
            if(ajax_event != null) {
                //$(zone_path).unbind(ajax_event);
                $(zone_path).bind(ajax_event, function() {
                    if($(zone_path).has($('#' + element_id)).length) {
                        if(!$('#' + fake_id).length) {
                            my_custom_form(type, zone_path, element_id, fake_id, element_addclass, wrapper_addclass, ajax_event);
                        }
                    }
                });
            }

            // Define element css path
            var my_element_path = zone_path + ' #' + element_id;

            // Check existing of our select element
            if($(my_element_path).length) {

                /* Define somes class variables */
                var my_wrapper_default_class       = 'mcf_wrapper_default_class';
                var my_fake_default_class          = 'mcf_fake_default_class';
                var my_element_default_class_show  = 'mcf_element_default_class_show';
                var my_element_default_class_hide  = 'mcf_element_default_class_hide';

                /* Define element's wrapper and fake element's css path */
                var my_wrapper_element  = $(my_element_path).parent();
                var my_fake_path        = zone_path + ' #' + fake_id;

                /* Define & takes some variables, depend if type of element form */
                if(type == 'select') {
                    var my_selected_option       = $(my_element_path).find(':selected').text();
                    var my_fake_element          = '<div id ="' + fake_id + '" class="' + my_fake_default_class + '">' + my_selected_option + '</div>';
                    var my_element_default_class = my_element_default_class_hide;
                }//if()
                else if(type == 'input_file') {
                    var my_fake_element          = '<div id ="' + fake_id + '" class="' + my_fake_default_class + '">Choisissez un fichier</div>';
                    var my_element_default_class = my_element_default_class_hide;
                }//else if
                else if (type == 'date_calendar') {
                    var my_fake_element          = '<div id="' + fake_id + '" class="' + my_fake_default_class + '">Date</div>';
                    var my_element_default_class = my_element_default_class_show;
                }//else if

                /* Add default and additional class on wrapper and element form */
                $(my_wrapper_element).addClass(my_wrapper_default_class);
                $(my_element_path).addClass(my_element_default_class);
                if (wrapper_addclass != null) {
                  $(my_wrapper_element).addClass(wrapper_addclass);
                }
                if (element_addclass != null) {
                  $(my_element_path).addClass(element_addclass);
                }

                /* Insert fake element */
                if(type == 'date_calendar') {
                    $(my_fake_path).remove();
                    // Need to check if we already have a value in our calendar before inserting our fake element (if the form already have been validate with a filter date)
                    if(!$(my_element_path).val()) {
                        $(my_wrapper_element).prepend(my_fake_element);
                    }//if()
                }//if()
                else {
                    // In other case, we can add our fake element
                    $(my_wrapper_element).prepend(my_fake_element);
                }//else()

                /* Element state's change : manipulate fake element with his value */
                $(my_element_path).change(function() {

                    // If we have a value in our date calendar, we have to remove the fake element or add it (no change value)
                    if (type == 'date_calendar') {
                        $(my_fake_path).remove();
                        if($(my_element_path).val()) {
                            $(my_fake_path).remove();
                        }//if()
                        else {
                            $(my_wrapper_element).prepend(my_fake_element);
                        }//else
                    }//if()
                    else {
                        // In those case, fake element have to be here : just change the value
                        if(type == 'select') {
                            var my_fake_element_value = $(my_element_path + ' option:selected').text();
                        }//if()
                        else if(type == 'input_file') {
                            var my_fake_element_value = get_file_name($(my_element_path).val());
                        }//else if()
                        $(my_fake_path).text(my_fake_element_value);
                    }//else

                });
            }
        }

        my_custom_input_text('#views-exposed-form-pmu-press-communique-page', '#edit-title-wrapper', '#edit-title');

        /**
         * v1.01
         * Take input field label value, and put it inside the input field.
         *s
         * Requiered params :
         * @params form_path : css path to the form
         * @params element_wrapper_path : css path, from the form, to the element & label wrapper
         * @params element : id or class of element input
         *
         * Optionals params (null by default) :
         * @params label: label element select (path start from element_wrapper_path). If null, will be "label"
         * @params submit: submit selector or path (path start from form_path) of submit button. If null, will be "input[type=submit]"
         */
        function my_custom_input_text(form_path, element_wrapper_path, element, label, submit) {
            var my_element = form_path + ' ' + element_wrapper_path + ' ' + element;

            if($(my_element)) {
                //Define label element
                if(label == null) {
                    var my_label = form_path + ' ' + element_wrapper_path + ' label';
                }
                else {
                    var my_label = form_path + ' ' + element_wrapper_path + ' ' + label;
                }

                // Define submit button
                if(submit == null) {
                    var my_submit = form_path + ' input[type=submit]';
                }
                else {
                    var my_submit = form_path + ' ' + submit;
                }

                // Define label value
                var my_label_text = $.trim($(my_label).text());

                // Hidding label
                $(my_label).hide();

                // Init : set label text for input value
                if(!$(my_element).val()) {
                    $(my_element).val(my_label_text);
                }

                // Focus : delete input value if dÃ©fault value
                $(my_element).click(function() {
                    if($(my_element).val() == my_label_text) {
                        $(my_element).val('');
                    }
                });

                // Blur : put label value if empty
                $(my_element).blur(function() {

                    if($(my_element).val() == '') {
                        $(my_element).val(my_label_text);
                    }
                });

                // Click submit : remove text label
                $(my_submit).click(function() {
                    if($(my_element).val() == my_label_text) {
                        $(my_element).val('');
                    }
                });
            }
        }
            var timer_diff = (new Date).getTime() - timer_start;
            //console.log('Execution time : ' + timer_diff + 'ms');

        });
    })(jQuery);
