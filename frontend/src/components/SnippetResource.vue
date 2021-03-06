<template>
  <div class="d-flex flex-column fill-height">
    <!-- dialogs -->
    <loading-dialog :active="deleting" message="Deleting" />
    <confirm-dialog
      :active="confirmDeleteDialog"
      prompt="Delete Note?"
      confirmMessage="delete"
      declineMessage="cancel"
      @confirm="deleteResource"
      @decline="confirmDeleteDialog = false"
    />
    <!-- main content -->

    <!-- back button -->
    <div class="d-flex my-6">
      <v-btn color="secondary" width="125" @click="$utils.goBack">
        <v-icon left>mdi-arrow-left</v-icon>Back
      </v-btn>
      <v-spacer></v-spacer>
      <responsive-button-group
        v-if="mode === 'read'"
        :items="actionItems"
        :collapse="$vuetify.breakpoint.mdAndDown"
        menuText="Actions"
        menuIcon="mdi-chevron-down"
        menuWidth="125"
      />

      <v-btn color="secondary" width="125" @click="save" v-else>
        <v-icon left color="green">mdi-check</v-icon>Save
      </v-btn>
    </div>
    <!-- header card -->
    <v-card class="px-6 py-4 mb-6">
      <resource-header v-if="mode === 'read'" :resource="resource" />
      <editable-resource-header v-if="mode === 'write'" :resource="resource" />
    </v-card>
    <!-- editor card -->
    <no-content
      v-if="resource.content == '' && mode === 'read'"
      callToAction="Click here to start editing."
      @engage="mode = 'write'"
      class="flex-grow-1"
    />
    <v-card
      v-else
      :class="'flex-grow-1 pa-6 d-flex flex-column ' + (this.$vuetify.theme.dark ? 'markdown-body-dark' : 'markdown-body-light')"
    >
      <div class="d-flex mb-6 align-center">
        <span v-if="mode === 'read'" class="title title-case">{{ selectedLanguage }}</span>
        <v-select
          :items="languages"
          label="Language"
          class="flex-grow-1 mr-12 short-text-field"
          single-line
          v-else
          v-model="selectedLanguage"
        ></v-select>
        <v-spacer v-if="mode === 'read'"></v-spacer>
        <v-btn @click="$utils.copyTextToClipboard(resource.content)">
          <v-icon left small>mdi-content-copy</v-icon>Copy
        </v-btn>
      </div>
      <codemirror
        v-model="resource.content"
        ref="cmEditor"
        :options="cmOptions"
        class="flex-grow-1 code-mirror-filler"
      ></codemirror>
    </v-card>
  </div>
</template>
<script>
import { codemirror } from "vue-codemirror";
import "codemirror/lib/codemirror.css";
import "codemirror/theme/base16-dark.css";

import "codemirror/mode/clike/clike.js";
import "codemirror/mode/css/css.js";
import "codemirror/mode/go/go.js";
import "codemirror/mode/htmlmixed/htmlmixed.js";
import "codemirror/mode/javascript/javascript.js";
import "codemirror/mode/python/python.js";
import "codemirror/mode/ruby/ruby.js";
import "codemirror/mode/vue/vue.js";

import LoadingDialog from "../components/LoadingDialog";
import EditableResourceHeader from "../components/EditableResourceHeader";
import ResourceHeader from "../components/ResourceHeader";
import ConfirmDialog from "../components/ConfirmDialog";
import ResponsiveButtonGroup from "@/components/ResponsiveButtonGroup";
import NoContent from "@/components/NoContent";

export default {
  components: {
    ConfirmDialog,
    LoadingDialog,
    EditableResourceHeader,
    ResourceHeader,
    ResponsiveButtonGroup,
    codemirror,
    NoContent,
  },
  props: ["resource", "editMode"],
  data() {
    var vm = this;
    return {
      mode: "read",
      fab: false,
      confirmDeleteDialog: false,
      deleting: false,
      cmOptions: {
        tabSize: 2,
        mode: null,
        theme: "base16-dark",
        lineNumbers: true,
        line: true,
        readOnly: "nocursor",
        lineWrapping: true,
      },
      languages: [
        { text: "No Language Selected", value: null },
        { text: "C", value: "clike" },
        { text: "C++", value: "clike" },
        { text: "CSS", value: "css" },
        { text: "Go", value: "go" },
        { text: "HTML", value: "htmlmixed" },
        { text: "Javascript", value: "javascript" },
        { text: "Python", value: "python" },
        { text: "Ruby", value: "ruby" },
        { text: "Vue", value: "vue" },
      ],
      selectedLanguage: null,
      actionItems: [
        {
          text: "Edit",
          icon: "mdi-pencil",
          buttonColor: "none",
          buttonWidth: "125",
          iconColor: "green",
          function: function () {
            vm.edit();
          },
        },
        {
          text: "Export",
          icon: "mdi-export",
          buttonColor: "none",
          buttonWidth: "125",
          iconColor: "blue",
          function: function () {
            vm.exportResource();
          },
        },
        {
          text: "Delete",
          icon: "mdi-delete",
          buttonColor: "none",
          buttonWidth: "125",
          iconColor: "red",
          function: function () {
            vm.confirmDeleteDialog = true;
          },
        },
      ],
    };
  },
  watch: {
    mode() {
      var vm = this;
      vm.cmOptions.readOnly = vm.mode === "read" ? "nocursor" : false;
    },
    selectedLanguage() {
      var vm = this;
      vm.cmOptions.mode = vm.selectedLanguage;
    },
  },
  created() {
    var vm = this;
    if (vm.editMode) {
      vm.mode = "write";
    }

    if (vm.resource.language) {
      vm.selectedLanguage = vm.resource.language;
    }
  },
  methods: {
    edit: function () {
      var vm = this;
      vm.mode = "write";
    },
    save: async function () {
      var vm = this;
      vm.mode = "read";
      await vm.$api.updateResource(
        vm.$route.params.stashId,
        vm.$route.params.resourceId,
        vm.resource.name,
        vm.resource.tags,
        vm.resource.content,
        vm.selectedLanguage
      );
    },
    deleteResource: async function () {
      var vm = this;
      vm.confirmDeleteDialog = false;
      vm.deleting = true;
      await vm.$api.deleteResource(
        vm.$route.params.stashId,
        vm.$route.params.resourceId
      );
      vm.deleting = false;
      vm.$utils.goBack();
    },
    exportResource: function () {
      var vm = this;
      vm.$utils.downloadObj(vm.resource, vm.resource.name);
    },
  },
};
</script>

<style lang="scss">
@import "../styles/markdown-light.scss";
@import "../styles/markdown-dark.scss";

.CodeMirror {
  height: auto !important;
}

// FIXME kinda hacky - solution is to download code mirror themes locally,
// add this class to the css file, with background color matching that
// of the theme
.code-mirror-filler {
  background-color: #151515;
}

:focus {
  outline: none;
}

// this is for the editor menu buttons
.menubar__button.v-btn:not(.v-btn--round).v-size--default {
  padding: 0;
  min-width: 0;
  min-height: 0;
  height: 3em;
  width: 3em;
  margin: 0.25em;
}

.markdown-body-dark {
  pre {
    &::before {
      content: attr(data-language);
      text-transform: uppercase;
      display: block;
      text-align: right;
      font-weight: bold;
      font-size: 0.6rem;
    }
    code {
      color: white !important;
      @import "highlight.js/scss/atom-one-dark.scss";
    }
  }
}

.markdown-body-light {
  pre {
    &::before {
      content: attr(data-language);
      text-transform: uppercase;
      display: block;
      text-align: right;
      font-weight: bold;
      font-size: 0.6rem;
    }
    code {
      color: black !important;
      @import "highlight.js/scss/atom-one-light.scss";
    }
  }
}
</style>