document.addEventListener('turbolinks:load', function () {
    if ($(".tags-input").length) {

        const ul = document.querySelector(".tags-ul"),
            input = document.querySelector(".tags-input"),
            tagNumb = document.querySelector(".tags-details span");

        let maxTags = 5
        tags = $('#issue_tag_list').val().split(',').filter(tag => tag.length > 0) || []
        countTags();
        createTag();

        function countTags() {
            input.focus();
            tagNumb.innerText = maxTags - tags.length;
        }

        function createTag() {
            ul.querySelectorAll(".tags-li").forEach(li => li.remove());
            tags.slice().reverse().forEach(tag => {
                let liTag = `<li class="tags-li" data-tag="${tag}">${tag} <i class="fa fa-remove remove-tag"></i></li>`;
                ul.insertAdjacentHTML("afterbegin", liTag);
            });
            removeIcon = document.querySelector(".remove-tag")
            if (removeIcon)
                removeIcon.addEventListener("click", remove);
            countTags();
            updateHiddenField()
        }
        function updateHiddenField() {
            $('#issue_tag_list').val(tags)
        }
        function showColors() {
            document.getElementById("myDropdown").classList.toggle("show");
        }
        function addTag(e) {
            if (e.key === ' ' || e.key === 'Spacebar') {
                let tag = ""
                if ($('.colors-dropdown').hasClass('open')) {
                    $('#Critical').focus();
                } else {
                    $('.colors-dropdown').addClass('open');
                }
                tag = e.target.value.replace(/\s+/g, ' ').slice(0, -1);
                if (tag.length > 1 && !tags.includes(tag)) {
                    if (tags.length < 10) {
                        tag.split(',').forEach(tag => {
                            tags.push(tag);
                            createTag();
                        });
                    }
                }
                e.target.value = "";
            }
        }
        function removeLatestTag(e) {
            if (e.keyCode == 8 & this.selectionStart == 0) {
                tags.pop()
                updateHiddenField()
                createTag()
            }
        }

        input.addEventListener("keyup", addTag);
        input.addEventListener("keyup", removeLatestTag);
        const removeBtn = document.querySelector(".tags-remove-btn");
        removeBtn.addEventListener("click", () => {
            tags.length = 0;
            ul.querySelectorAll("li").forEach(li => li.remove());
            countTags();
        });
        function remove() {
            let index = tags.indexOf(this.parentElement.dataset.tag);
            tags = [...tags.slice(0, index), ...tags.slice(index + 1)];
            this.parentElement.remove();
            countTags();
        }
    }
});
